#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: tests/php-http-security.sh [--no-php] IMAGE DOCROOT [additional-denied-path...]" >&2
    exit 2
}

# Images without a PHP handler have no executing entrypoint to keep working
php_entrypoint=true
if [ "${1:-}" = "--no-php" ]; then
    php_entrypoint=false
    shift
fi

IMAGE=${1:-}
DOCROOT=${2:-}
[ -n "$IMAGE" ] && [ -n "$DOCROOT" ] || usage
shift 2

# The daemon publishes on this address, the requests reach it through this host.
# They differ whenever the daemon is not the machine running this script.
publish_address=${TEST_PUBLISH_ADDRESS:-127.0.0.1}
test_host=${TEST_HOST:-$publish_address}

denied_paths=(
    SECRET.PHP
    secret.php5
    secret.phps
    secret.pht
    secret.phtm
    secret.phtml
    secret.phar
    secret.inc
    secret.php.bak
    'secret.php~'
    dump.sql
    config.yml.bak
    "$@"
)
if [ "$php_entrypoint" != true ]; then
    denied_paths+=(index.php)
fi
static_paths=(vendor.include.js foo.incident.json phpstorm.svg sqlite3.map.js .well-known/security.txt)

fixture_dir=$(mktemp -d)
chmod 755 "$fixture_dir"
override_dir=$(mktemp -d)
chmod 755 "$override_dir"
container_id=""

cleanup() {
    if [ -n "$container_id" ]; then
        docker rm -f "$container_id" >/dev/null 2>&1 || true
    fi
    rm -rf -- "$fixture_dir" "$override_dir"
}
trap cleanup EXIT

printf '%s\n' \
    '<?php' \
    "printf('front-controller|%s|%s|%s', \$_SERVER['HTTPS'], \$_SERVER['HTTP_SCHEME'], \$_SERVER['SERVER_PORT']);" \
    > "$fixture_dir/index.php"
# PATH_INFO cases share the file name in front of the first slash
for denied_path in "${denied_paths[@]}"; do
    printf '%s\n' '<?php echo "source-disclosed";' > "$fixture_dir/${denied_path%%/*}"
done
for static_path in "${static_paths[@]}"; do
    mkdir -p "$fixture_dir/$(dirname "$static_path")"
    printf '%s\n' 'static-file' > "$fixture_dir/$static_path"
done
printf '%s\n' 'APP_SECRET=source-disclosed' > "$fixture_dir/.env"

# A peer outside the trusted ranges must not be able to assert the external scheme
printf '%s\n' \
    'geo $realip_remote_addr $trusted_proxy {' \
    '    default 0;' \
    '}' \
    > "$override_dir/06-trusted-proxy.conf"

start_container() {
    local extra_mount=("$@")
    container_id=$(docker run -d --rm \
        -p "$publish_address::8080" \
        -v "$fixture_dir:$DOCROOT:ro" \
        ${extra_mount[@]+"${extra_mount[@]}"} \
        "$IMAGE")
    host_port=$(docker port "$container_id" 8080/tcp | awk -F: 'NR == 1 { print $NF }')
    base_url="http://$test_host:$host_port"

    # nginx answers before PHP-FPM has its socket, so probe the entrypoint itself
    local ready_url="$base_url/index.php"
    if [ "$php_entrypoint" != true ]; then
        ready_url="$base_url/nginx-health"
    fi

    for _ in $(seq 1 30); do
        if curl --fail --silent "$ready_url" >/dev/null; then
            return 0
        fi
        sleep 1
    done
    curl --fail --silent --show-error "$ready_url" >/dev/null
}

stop_container() {
    docker rm -f "$container_id" >/dev/null
    container_id=""
}

start_container

for denied_path in "${denied_paths[@]}"; do
    status=$(curl --silent --show-error \
        --output "$override_dir/response" \
        --write-out '%{http_code}' \
        "$base_url/$denied_path")
    if [ "$status" != 404 ]; then
        echo "Expected /$denied_path to return 404, got $status." >&2
        exit 1
    fi
    if grep -q 'source-disclosed' "$override_dir/response"; then
        echo "Server-side source was disclosed by nginx at /$denied_path." >&2
        exit 1
    fi
done

# Other hidden paths stay blocked while /.well-known/ is public
status=$(curl --silent --output /dev/null --write-out '%{http_code}' "$base_url/.env")
if [ "$status" = 200 ]; then
    echo "Expected /.env to be blocked, got $status." >&2
    exit 1
fi

for static_path in "${static_paths[@]}"; do
    response=$(curl --fail --silent --show-error "$base_url/$static_path")
    if [ "$response" != 'static-file' ]; then
        echo "Expected /$static_path to remain a static file." >&2
        exit 1
    fi
done

if [ "$php_entrypoint" != true ]; then
    exit 0
fi

response=$(curl --fail --silent --show-error "$base_url/index.php")
if [ "$response" != 'front-controller|off|http|80' ]; then
    echo "Expected plain request metadata, got '$response'." >&2
    exit 1
fi

response=$(curl --fail --silent --show-error \
    -H 'X-Forwarded-Proto: https' "$base_url/index.php")
if [ "$response" != 'front-controller|on|https|443' ]; then
    echo "Expected a trusted proxy to set HTTPS metadata, got '$response'." >&2
    exit 1
fi

stop_container
start_container -v "$override_dir/06-trusted-proxy.conf:/etc/nginx/http.d/06-trusted-proxy.conf:ro"

for forged_header in 'X-Forwarded-Proto: https' 'X-Use-Https: on'; do
    response=$(curl --fail --silent --show-error -H "$forged_header" "$base_url/index.php")
    if [ "$response" != 'front-controller|off|http|80' ]; then
        echo "Untrusted peer forged the request scheme with '$forged_header': '$response'." >&2
        exit 1
    fi
done
