#!/bin/sh

# Exit on error
set -ex

# Configuration
[ -z "$PHP_MAJOR_VERSION" ] && echo "PHP_MAJOR_VERSION is not set" && exit 1;
[ -z "$PHP_MINOR_VERSION" ] && echo "PHP_MINOR_VERSION is not set" && exit 1;

# Add repository
ALPINE_VERSION=`cat /etc/alpine-release | cut -d'.' -f-2`
wget -O /etc/apk/keys/php-alpine.rsa.pub https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub
echo "@php https://dl.bintray.com/php-alpine/v$ALPINE_VERSION/php-$PHP_MINOR_VERSION" >> /etc/apk/repositories

# Install PHP, composer and git with SSH support
apk add --no-cache php@php \
    php-apcu@php \
    php-calendar@php \
    php-common@php \
    php-curl@php \
    php-ctype@php \
    php-dom@php \
    php-gd@php \
    php-iconv@php \
    php-imagick@php \
    php-intl@php \
    php-json@php \
    php-ldap@php \
    php-mbstring@php \
    php-mysqli@php \
    php-mysqlnd@php \
    php-opcache@php \
    php-openssl@php \
    php-pcntl@php \
    php-pdo@php \
    php-pdo_mysql@php \
    php-pdo_sqlite@php \
    php-phar@php \
    php-posix@php \
    php-session@php \
    php-soap@php \
    php-xml@php \
    php-xmlreader@php \
    php-zip@php \
    php-zlib@php \
    git \
    openssh-client

# Configure PHP
sed -i "s/upload_max_filesize.*/upload_max_filesize = 128M/g" /etc/php$PHP_MAJOR_VERSION/php.ini
sed -i "s/post_max_size.*/post_max_size = 128M/g" /etc/php$PHP_MAJOR_VERSION/php.ini
echo "error_log = /dev/stderr" >> /etc/php$PHP_MAJOR_VERSION/php.ini
echo "php_admin_value[upload_max_filesize] = 128M" >> /etc/php$PHP_MAJOR_VERSION/php.ini
echo "date.timezone = Europe/Zurich" >> /etc/php$PHP_MAJOR_VERSION/php.ini

# Add CLI symlink
ln -s /usr/bin/php$PHP_MAJOR_VERSION /usr/bin/php

# Install prestissimo
wget -O - https://getcomposer.org/installer | php -- --quiet --1 --install-dir /usr/bin/ --filename composer
