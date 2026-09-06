#!/bin/sh
set -eu
export DEBIAN_FRONTEND=noninteractive

# The upstream maintainers publish separate repositories per PHP major/minor.
# This image uses ZTS throughout; Sury's non-thread-safe extensions cannot load.
test "$PHP_VERSION" = 8.5
ZTS_KEY_FPR=71531E1582BE72B3E0479B8BC290E47D98B7D254
import-apt-key.sh \
    https://pkg.henderkes.com/api/packages/85/debian/repository.key \
    "$ZTS_KEY_FPR" /etc/apt/keyrings/php-zts.gpg
echo 'deb [signed-by=/etc/apt/keyrings/php-zts.gpg] https://pkg.henderkes.com/api/packages/85/debian php-zts main' \
    > /etc/apt/sources.list.d/php-zts.list

apt-get update
apt-get install -y --no-install-recommends \
    frankenphp php-zts-cli php-zts-apcu php-zts-bcmath php-zts-gd \
    php-zts-imagick php-zts-intl php-zts-mysqli php-zts-pdo-mysql \
    php-zts-pgsql php-zts-pdo-pgsql \
    php-zts-soap php-zts-sqlite3 php-zts-pdo-sqlite php-zts-zip \
    ghostscript unzip
rm -rf /var/lib/apt/lists/*

# A real CLI binary also supports Composer's @php scripts and PHP CLI flags.
ln -sf /usr/bin/php-zts /usr/local/bin/php
php -r 'exit(PHP_ZTS && PHP_MAJOR_VERSION === 8 && PHP_MINOR_VERSION === 5 ? 0 : 1);'
mkdir -p /etc/php/8.5/conf.d
cat > /etc/php/8.5/conf.d/99-whatwedo.ini <<'INI'
memory_limit = ${PHP_MEMORY_LIMIT}
upload_max_filesize = 128M
post_max_size = 128M
date.timezone = ${TZ}
expose_php = Off
error_log = /dev/stderr
INI

# Use the same verified Composer 2 installer as the other PHP images.
expected_checksum="$(curl -fsS https://composer.github.io/installer.sig)"
curl -fsS https://getcomposer.org/installer -o /tmp/composer-setup.php
actual_checksum="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
if [ "$expected_checksum" != "$actual_checksum" ]; then
    rm -f /tmp/composer-setup.php
    echo 'ERROR: Invalid Composer installer checksum' >&2
    exit 1
fi
php /tmp/composer-setup.php --quiet --2 --install-dir=/usr/local/bin --filename=composer
rm -f /tmp/composer-setup.php
