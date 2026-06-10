#!/bin/sh
set -ex

[ -z "$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1

# Add Sury PHP repository
apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -sSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/sury-php.gpg
echo "deb [signed-by=/etc/apt/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list

# Install PHP and extensions
# Note: opcache, pcntl, pdo, phar, posix, simplexml, tokenizer, xmlreader, xmlwriter
# are typically included in php-common and don't have separate packages
apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION} \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    imagemagick \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP
PHP_INI="/etc/php/${PHP_VERSION}/cli/php.ini"
sed -i "s/upload_max_filesize.*/upload_max_filesize = 128M/" "$PHP_INI"
sed -i "s/post_max_size.*/post_max_size = 128M/" "$PHP_INI"
echo "error_log = /dev/stderr" >> "$PHP_INI"
echo "date.timezone = Europe/Zurich" >> "$PHP_INI"
echo "expose_php = Off" >> "$PHP_INI"

# Create shared conf.d directory for configs used by both CLI and FPM
mkdir -p "/etc/php/${PHP_VERSION}/conf.d"

# Ensure php symlink
[ ! -f /usr/bin/php ] && ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# Install Composer (verify installer against the official SHA-384 signature)
EXPECTED_CHECKSUM="$(curl -sS https://composer.github.io/installer.sig)"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo "ERROR: Invalid composer installer checksum" >&2
    rm -f /tmp/composer-setup.php
    exit 1
fi
php /tmp/composer-setup.php --quiet --2 --install-dir=/usr/bin/ --filename=composer
rm -f /tmp/composer-setup.php

