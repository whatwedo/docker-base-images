#!/bin/bash
set -euo pipefail

IMAGE=${1:?Usage: tests/symfony-runtime.sh IMAGE}
SHUTDOWN_TIMEOUT=${SHUTDOWN_TIMEOUT:-8}

if ! [[ "$SHUTDOWN_TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
    echo "SHUTDOWN_TIMEOUT must be a positive integer." >&2
    exit 2
fi
DOCKER_STOP_TIMEOUT=${DOCKER_STOP_TIMEOUT:-$((SHUTDOWN_TIMEOUT + 2))}

# The daemon publishes on this address, the requests reach it through this host.
# They differ whenever the daemon is not the machine running this script.
publish_address=${TEST_PUBLISH_ADDRESS:-127.0.0.1}
test_host=${TEST_HOST:-$publish_address}

fixture_dir=$(mktemp -d)
chmod 755 "$fixture_dir"
container_id=""
curl_pid=""

cleanup() {
    if [ -n "$curl_pid" ]; then
        kill "$curl_pid" 2>/dev/null || true
        wait "$curl_pid" 2>/dev/null || true
    fi
    if [ -n "$container_id" ]; then
        docker rm -f "$container_id" >/dev/null 2>&1 || true
    fi
    rm -rf -- "$fixture_dir"
}
trap cleanup EXIT

printf '%s\n' \
    '<?php' \
    "if (\$_SERVER['REQUEST_URI'] === '/slow') {" \
    "    touch('/tmp/slow-started');" \
    '    sleep(3);' \
    "    echo 'request-completed';" \
    '    return;' \
    '}' \
    "echo 'front-controller';" \
    > "$fixture_dir/index.php"

container_id=$(docker run -d --rm \
    -e "SHUTDOWN_TIMEOUT=$SHUTDOWN_TIMEOUT" \
    -p "$publish_address::8080" \
    -v "$fixture_dir:/var/www/public:ro" \
    "$IMAGE")

host_port=$(docker port "$container_id" 8080/tcp | awk -F: 'NR == 1 { print $NF }')
base_url="http://$test_host:$host_port"

# nginx answers before PHP-FPM has its socket, so probe the front controller
for _ in $(seq 1 30); do
    if curl --fail --silent "$base_url/" >/dev/null; then
        break
    fi
    sleep 1
done
curl --fail --silent --show-error "$base_url/" >/dev/null

curl --fail --silent --show-error "$base_url/slow" > "$fixture_dir/slow-response" &
curl_pid=$!

slow_started=false
for _ in $(seq 1 30); do
    if docker exec "$container_id" test -f /tmp/slow-started; then
        slow_started=true
        break
    fi
    sleep 0.1
done
if [ "$slow_started" != true ]; then
    echo "Slow request did not reach PHP-FPM before shutdown." >&2
    exit 1
fi

docker stop --timeout "$DOCKER_STOP_TIMEOUT" "$container_id" >/dev/null
container_id=""

wait "$curl_pid"
curl_pid=""
grep -qx 'request-completed' "$fixture_dir/slow-response"
