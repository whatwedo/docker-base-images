#!/bin/sh

# Exit on error
set -e

# Configuration
PHP_VERSION=7.3

# Install build dependencies
apk add --no-cache --virtual .build-deps curl

# Add repository
ALPINE_VERSION=`cat /etc/alpine-release | cut -d'.' -f-2`
curl https://php.codecasts.rocks/php-alpine.rsa.pub -o /etc/apk/keys/php-alpine.rsa.pub
echo "@php https://php.codecasts.rocks/v$ALPINE_VERSION/php-$PHP_VERSION" >> /etc/apk/repositories

# Remove build dependencies
apk del .build-deps

# Install PHP
# TODO: Add php-memcached if available on PHP 7.3
apk add --no-cache php@php \
    php-apcu@php \
    php-common@php \
    php-curl@php \
    php-imagick@php \
    php-intl@php \
    php-json@php \
    php-ldap@php \
    php-mbstring@php \
    php-pdo_mysql@php \
    php-pdo_sqlite@php \
    php-soap@php \
    php-xml@php \
    php-zip@php

# Add CLI symlink
ln -s /usr/bin/php`echo $PHP_VERSION | cut -d'.' -f 1` /usr/bin/php
