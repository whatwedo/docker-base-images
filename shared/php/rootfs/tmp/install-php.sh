#!/bin/sh

# Exit on error
set -ex

# Configuration
[ -z "$PHP_MAJOR_VERSION" ] && echo "PHP_MAJOR_VERSION is not set" && exit 1;
[ -z "$PHP_MINOR_VERSION" ] && echo "PHP_MINOR_VERSION is not set" && exit 1;

# Install build dependencies
apk add --no-cache --virtual .build-deps curl

# Add repository
ALPINE_VERSION=`cat /etc/alpine-release | cut -d'.' -f-2`
curl https://php.codecasts.rocks/php-alpine.rsa.pub -o /etc/apk/keys/php-alpine.rsa.pub
echo "@php https://php.codecasts.rocks/v$ALPINE_VERSION/php-$PHP_MINOR_VERSION" >> /etc/apk/repositories

# Remove build dependencies
apk del --no-cache .build-deps

# Install PHP, composer and git
apk add --no-cache php@php \
    php-apcu@php \
    php-common@php \
    php-curl@php \
    php-ctype@php \
    php-dom@php \
    php-iconv@php \
    php-imagick@php \
    php-intl@php \
    php-json@php \
    php-ldap@php \
    php-mbstring@php \
    php-memcached@php \
    php-opcache@php \
    php-pcntl@php \
    php-pdo_mysql@php \
    php-pdo_sqlite@php \
    php-phar@php \
    php-posix@php \
    php-session@php \
    php-soap@php \
    php-xml@php \
    php-zip@php \
    composer \
    git

# Configure PHP
sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php$PHP_MAJOR_VERSION/php.ini
sed -i s/^post_max_size.*/post_max_size\ =\ 50M/g /etc/php$PHP_MAJOR_VERSION/php.ini
sed -i s/^memory_limit.*/memory_limit\ =\ \-1/g /etc/php$PHP_MAJOR_VERSION/php.ini
echo "error_log = /dev/stderr" >> /etc/php$PHP_MAJOR_VERSION/php.ini

# Add CLI symlink
ln -s /usr/bin/php$PHP_MAJOR_VERSION /usr/bin/php

# Install prestissimo
composer global require hirak/prestissimo
composer clearcache
