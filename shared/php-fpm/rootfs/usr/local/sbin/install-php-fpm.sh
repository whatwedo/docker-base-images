#!/bin/sh
set -ex
export DEBIAN_FRONTEND=noninteractive

[ -z "$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1
printf '%s\n' "$PHP_VERSION" | grep -Eq '^[0-9]+\.[0-9]+$' || {
    echo "PHP_VERSION must be a major.minor version (for example 8.5)" >&2
    exit 1
}

apt-get update && apt-get install -y --no-install-recommends \
    systemd-standalone-tmpfiles \
    php${PHP_VERSION}-fpm \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/machine-id /var/lib/dbus/machine-id

# Debian PHP-FPM paths
FPM_CONF="/etc/php/${PHP_VERSION}/fpm/php-fpm.conf"
POOL_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

# Configure PHP-FPM main config
sed -i 's,^;*error_log = .*,error_log = /proc/self/fd/2,' "$FPM_CONF"
sed -i 's,^;*pid = .*,pid = /tmp/php-fpm.pid,' "$FPM_CONF"

# Configure pool — run as app user.
# Directives that Debian's www.conf already contains are rewritten in place, so
# the pool never carries a Debian default and our value for the same key.
sed -i 's,^;*user = .*,user = app,' "$POOL_CONF"
sed -i 's,^;*group = .*,group = app,' "$POOL_CONF"
sed -i 's,^;*listen = .*,listen = /tmp/php-fpm.sock,' "$POOL_CONF"
sed -i 's,^;*listen.owner = .*,listen.owner = app,' "$POOL_CONF"
sed -i 's,^;*listen.group = .*,listen.group = app,' "$POOL_CONF"
sed -i 's,^;*pm.max_children = .*,pm.max_children = 32,' "$POOL_CONF"
sed -i 's,^;*pm.start_servers = .*,pm.start_servers = 2,' "$POOL_CONF"
sed -i 's,^;*pm.min_spare_servers = .*,pm.min_spare_servers = 2,' "$POOL_CONF"
sed -i 's,^;*pm.max_spare_servers = .*,pm.max_spare_servers = 8,' "$POOL_CONF"
sed -i 's,^;*pm.max_requests = .*,pm.max_requests = 500,' "$POOL_CONF"
sed -i 's,^;*request_terminate_timeout = .*,request_terminate_timeout = 120s,' "$POOL_CONF"
sed -i 's,^;*clear_env = .*,clear_env = no,' "$POOL_CONF"
sed -i 's,^;*catch_workers_output = .*,catch_workers_output = yes,' "$POOL_CONF"

# FPM-only PHP settings, appended because www.conf ships no such entries —
# everything shared with the CLI lives in conf.d/99-whatwedo.ini
echo "php_admin_value[memory_limit] = 128M" >> "$POOL_CONF"
echo "php_flag[display_errors] = off" >> "$POOL_CONF"
echo "php_admin_flag[log_errors] = on" >> "$POOL_CONF"

# Runtime service paths and process checks are generated from the build-time
# version so overriding an environment variable cannot break the supervisor.
sed -i "s/@PHP_VERSION@/${PHP_VERSION}/g" \
    /etc/runit/runsvdir/default/php-fpm/run \
    /etc/goss/conf.d/php-fpm.yaml
