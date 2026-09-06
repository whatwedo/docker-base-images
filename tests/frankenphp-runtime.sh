#!/bin/bash
set -euo pipefail

IMAGE=${1:?Usage: tests/frankenphp-runtime.sh IMAGE}
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
publish_address=${TEST_PUBLISH_ADDRESS:-127.0.0.1}
test_host=${TEST_HOST:-$publish_address}
fixtures=$(mktemp -d)
chmod 755 "$fixtures"
cid=""
curl_pid=""

cleanup() {
    if [ -n "$curl_pid" ]; then
        kill "$curl_pid" 2>/dev/null || true
        wait "$curl_pid" 2>/dev/null || true
    fi
    if [ -n "$cid" ]; then
        docker logs "$cid" >&2 || true
        docker rm -f "$cid" >/dev/null 2>&1 || true
    fi
    rm -rf "$fixtures"
}
trap cleanup EXIT

cat > "$fixtures/index.php" <<'PHP'
<?php
if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/slow') {
    touch('/tmp/slow-started');
    sleep(3);
    echo 'request-completed';
    return;
}
if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/runtime') {
    echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION . '|' . PHP_ZTS . '|' . posix_geteuid() . '|' . date_default_timezone_get();
    return;
}
if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/client') {
    echo $_SERVER['REMOTE_ADDR'];
    return;
}
if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/memory') {
    echo ini_get('memory_limit');
    return;
}
echo ($_SERVER['HTTPS'] ?? 'off') . '|' . ($_SERVER['HTTP_SCHEME'] ?? '') . '|' . $_SERVER['SERVER_PORT'];
PHP
cp "$DIR/fixtures/imagick-pdf.php" "$fixtures/pdf.php"
denied=(SECRET.PHP secret.php5 secret.phps secret.phtml secret.pht secret.phar secret.inc secret.php.bak 'secret.php~' dump.sql config.yml.bak .env)
for path in "${denied[@]}"; do
    printf '%s\n' '<?php echo "source-disclosed";' > "$fixtures/$path"
done
mkdir -p "$fixtures/.well-known" "$fixtures/route.d"
for path in vendor.include.js foo.incident.json phpstorm.svg sqlite3.map.js .well-known/security.txt; do
    printf '%s' 'static-file' > "$fixtures/$path"
done
# A project drop-in, an emptied base file and a replacement catch-all.
printf '%s\n' 'respond /ping "pong" 200' > "$fixtures/route.d/50-ping.conf"
: > "$fixtures/route.d/90-php-server.conf"
printf '%s\n' 'respond "catch-all" 200' > "$fixtures/route.d/95-catch-all.conf"

start() {
    cid=$(docker run -d --rm --cap-drop=ALL --security-opt=no-new-privileges \
        -e PHP_VERSION=99.99 -e TZ=UTC \
        -p "$publish_address::8080" -v "$fixtures:/var/www/public:ro" "$@" "$IMAGE")
    port=$(docker port "$cid" 8080/tcp | awk -F: 'NR == 1 {print $NF}')
    url="http://$test_host:$port"
    for _ in $(seq 1 30); do
        if curl -fsS --max-time 5 "$url/frankenphp-health" >/dev/null 2>&1; then
            return
        fi
        sleep 1
    done
    echo 'FrankenPHP did not become ready' >&2
    return 1
}

stop() {
    docker stop --timeout 10 "$cid" >/dev/null
    cid=""
}

expect() {
    local expected="$1"
    shift
    local actual
    actual=$(curl -fsS "$@")
    if [ "$actual" != "$expected" ]; then
        printf 'Expected %s, got %s\n' "$expected" "$actual" >&2
        return 1
    fi
}

drain() {
    curl -fsS "$url/slow" > "$fixtures/slow-response" &
    curl_pid=$!
    for _ in $(seq 1 50); do
        if docker exec "$cid" test -f /tmp/slow-started; then
            break
        fi
        sleep 0.1
    done
    docker exec "$cid" test -f /tmp/slow-started
    stop
    wait "$curl_pid"
    curl_pid=""
    test "$(cat "$fixtures/slow-response")" = request-completed
}

start
expect '8.5|1|10000|UTC' "$url/runtime"
expect 'off|http|80' "$url/"
expect 'on|https|443' -H 'X-Forwarded-Proto: https' "$url/"
expect 'on|https|443' -H 'X-Use-Https: on' "$url/"
expect '203.0.113.42' -H 'X-Forwarded-For: 203.0.113.42' "$url/client"
for path in "${denied[@]}" '%2eenv' secret.php%2ebak; do
    status=$(curl -sS -o "$fixtures/response" -w '%{http_code}' "$url/$path")
    test "$status" = 404 || { echo "Expected 404 for $path, got $status" >&2; exit 1; }
    ! grep -q source-disclosed "$fixtures/response"
done
for path in vendor.include.js foo.incident.json phpstorm.svg sqlite3.map.js .well-known/security.txt; do
    expect static-file "$url/$path"
done
expect 128M "$url/memory"
test "$(docker exec "$cid" php -r 'echo ini_get("memory_limit");')" = -1
# Imagick must also work in FrankenPHP's threaded HTTP SAPI, not just in CLI.
for _ in 1 2 3; do
    expect 'Imagick PDF rendering passed.' "$url/pdf.php"
done
docker exec "$cid" sh -c "grep -Eq '^CapEff:[[:space:]]+0+$' /proc/1/status && grep -Eq '^NoNewPrivs:[[:space:]]+1$' /proc/1/status"
docker exec "$cid" sv restart /etc/runit/runsvdir/default/frankenphp
docker exec "$cid" goss --gossfile /etc/goss/conf.d/frankenphp.yaml validate --retry-timeout 30s --sleep 1s
drain
echo 'FrankenPHP classic, source protection, PDF and graceful shutdown passed.'

start -e FRANKENPHP_TRUSTED_PROXIES=192.0.2.0/24
expect 'off|http|80' -H 'X-Forwarded-Proto: https' -H 'X-Use-Https: on' "$url/"
peer=$(curl -fsS "$url/client")
expect "$peer" -H 'X-Forwarded-For: 203.0.113.42' -H 'X-Real-IP: 203.0.113.42' "$url/client"
stop
echo 'FrankenPHP rejects scheme assertions from untrusted peers.'

start -e FRANKENPHP_MEMORY_LIMIT=256M -e PHP_MEMORY_LIMIT=512M
expect 256M "$url/memory"
test "$(docker exec "$cid" php -r 'echo ini_get("memory_limit");')" = 512M
stop
echo 'FrankenPHP applies separate HTTP and CLI memory limits.'

start -v "$fixtures/route.d/50-ping.conf:/etc/frankenphp/route.d/50-ping.conf:ro" \
    -v "$fixtures/route.d/90-php-server.conf:/etc/frankenphp/route.d/90-php-server.conf:ro" \
    -v "$fixtures/route.d/95-catch-all.conf:/etc/frankenphp/route.d/95-catch-all.conf:ro"
expect pong "$url/ping"
expect catch-all "$url/"
expect catch-all "$url/runtime"
status=$(curl -sS -o /dev/null -w '%{http_code}' "$url/.env")
test "$status" = 404
stop
echo 'FrankenPHP route drop-ins extend, empty and replace the base files.'

cat > "$fixtures/index.php" <<'PHP'
<?php
$requests = 0;
while (frankenphp_handle_request(function () use (&$requests) {
    ++$requests;
    if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/slow') {
        touch('/tmp/slow-started');
        sleep(3);
        echo 'request-completed';
        return;
    }
    echo $requests . '|' . ($_GET['value'] ?? 'empty') . '|' . ($_SERVER['HTTPS'] ?? 'off');
})) {}
PHP
start -e 'FRANKENPHP_CONFIG=worker /var/www/public/index.php 1'
expect '1|first|off' "$url/?value=first"
expect '2|empty|on' -H 'X-Forwarded-Proto: https' "$url/"
expect '3|empty|off' "$url/"
drain
echo 'FrankenPHP worker persistence, request isolation and graceful shutdown passed.'
