#!/bin/sh
set -ex

[ -z "$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1

apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-fpm \
    && rm -rf /var/lib/apt/lists/*

# Debian PHP-FPM paths
FPM_CONF="/etc/php/${PHP_VERSION}/fpm/php-fpm.conf"
POOL_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
FPM_PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"

# Configure PHP-FPM main config
sed -i 's,^;*error_log = .*,error_log = /proc/self/fd/2,' "$FPM_CONF"
sed -i 's,^;*pid = .*,pid = /tmp/php-fpm.pid,' "$FPM_CONF"

# Configure pool — run as app user
sed -i 's,^listen = .*,listen = /tmp/php-fpm.sock,' "$POOL_CONF"
sed -i 's,^user = .*,user = app,' "$POOL_CONF"
sed -i 's,^group = .*,group = app,' "$POOL_CONF"
echo "listen.owner = app" >> "$POOL_CONF"
echo "listen.group = app" >> "$POOL_CONF"
echo "php_admin_value[upload_max_filesize] = 128M" >> "$POOL_CONF"
echo "php_admin_value[post_max_size] = 128M" >> "$POOL_CONF"
echo "php_flag[display_errors] = off" >> "$POOL_CONF"
echo "php_admin_flag[log_errors] = on" >> "$POOL_CONF"
echo "php_admin_value[memory_limit] = 128M" >> "$POOL_CONF"
echo "php_admin_value[date.timezone] = Europe/Zurich" >> "$POOL_CONF"
echo "php_flag[expose_php] = Off" >> "$POOL_CONF"
sed -i 's/^pm.max_children.*/pm.max_children = 32/' "$POOL_CONF"
sed -i 's/^pm.start_servers.*/pm.start_servers = 2/' "$POOL_CONF"
echo 'pm.min_spare_servers = 2' >> "$POOL_CONF"
echo 'pm.max_spare_servers = 8' >> "$POOL_CONF"
echo "clear_env = no" >> "$POOL_CONF"
echo "catch_workers_output = yes" >> "$POOL_CONF"

# Configure FPM php.ini
sed -i "s/upload_max_filesize.*/upload_max_filesize = 128M/" "$FPM_PHP_INI"
sed -i "s/post_max_size.*/post_max_size = 128M/" "$FPM_PHP_INI"
echo "error_log = /dev/stderr" >> "$FPM_PHP_INI"
echo "date.timezone = Europe/Zurich" >> "$FPM_PHP_INI"
