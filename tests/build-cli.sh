#!/bin/bash

# Exercises the manifest handling of build.sh. Runs without Docker.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$DIR/build.sh"
failures=0

check() {
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "ok - $label"
    else
        echo "not ok - $label" >&2
        echo "    expected: $expected" >&2
        echo "    actual:   $actual" >&2
        failures=$((failures + 1))
    fi
}

check_fails() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "not ok - $label (command unexpectedly succeeded)" >&2
        failures=$((failures + 1))
    else
        echo "ok - $label"
    fi
}

check "list keeps the build order" \
    "base php nodejs nginx nginx-php symfony frankenphp" \
    "$(VERSION=test "$BUILD" list | tr '\n' ' ' | sed 's/ $//')"

check "info reports the parent" \
    "nginx-php" \
    "$(VERSION=test "$BUILD" info symfony | awk '/^parent:/ {print $2}')"

check "info reports the health contract" \
    "no" \
    "$(VERSION=test "$BUILD" info php | awk '/^health:/ {print $2}')"

check "info reports the test suites" \
    "goss imagick-pdf http-security runtime" \
    "$(VERSION=test "$BUILD" info symfony | sed -n 's/^tests: //p')"

check_fails "unknown image is rejected" env VERSION=test "$BUILD" info nope

out_of_order="$(mktemp)"
printf 'php base no goss\nbase - no goss\n' > "$out_of_order"
check_fails "parent below its child is rejected" \
    env VERSION=test IMAGES_FILE="$out_of_order" "$BUILD" list
rm -f "$out_of_order"

echo
if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed" >&2
    exit 1
fi
echo "all checks passed"
