#!/bin/sh

# Exit on error
set -ex

# Configuration
[ -z "php$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1;

echo "@edge-testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Install PHP, composer and git with SSH support
apk add --no-cache libavif@edge-community
apk add --no-cache php$PHP_VERSION@edge-testing \
    php$PHP_VERSION\-apcu@edge-testing \
    php$PHP_VERSION\-bcmath@edge-testing \
    php$PHP_VERSION\-calendar@edge-testing \
    php$PHP_VERSION\-common@edge-testing \
    php$PHP_VERSION\-ctype@edge-testing \
    php$PHP_VERSION\-curl@edge-testing \
    php$PHP_VERSION\-dev@edge-testing \
    php$PHP_VERSION\-dom@edge-testing \
    php$PHP_VERSION\-fileinfo@edge-testing \
    php$PHP_VERSION\-gd@edge-testing \
    php$PHP_VERSION\-iconv@edge-testing \
    php$PHP_VERSION\-intl@edge-testing \
    php$PHP_VERSION\-json@edge-testing \
    php$PHP_VERSION\-mbstring@edge-testing \
    php$PHP_VERSION\-mysqli@edge-testing \
    php$PHP_VERSION\-mysqlnd@edge-testing \
    php$PHP_VERSION\-opcache@edge-testing \
    php$PHP_VERSION\-openssl@edge-testing \
    php$PHP_VERSION\-pcntl@edge-testing \
    php$PHP_VERSION\-pdo@edge-testing \
    php$PHP_VERSION\-pdo_mysql@edge-testing \
    php$PHP_VERSION\-pdo_sqlite@edge-testing \
    php$PHP_VERSION\-pear@edge-testing \
    php$PHP_VERSION\-phar@edge-testing \
    php$PHP_VERSION\-posix@edge-testing \
    php$PHP_VERSION\-session@edge-testing \
    php$PHP_VERSION\-simplexml@edge-testing \
    php$PHP_VERSION\-soap@edge-testing \
    php$PHP_VERSION\-tokenizer@edge-testing \
    php$PHP_VERSION\-xml@edge-testing \
    php$PHP_VERSION\-xmlreader@edge-testing \
    php$PHP_VERSION\-xmlwriter@edge-testing \
    php$PHP_VERSION\-zip@edge-testing \
    php$PHP_VERSION\-zlib@edge-testing \
    git \
    openssh-client \
    libavif@edge-community \
    libheif@edge-community \
    libgomp \
    imagemagick \
    imagemagick-dev \
    gcc \
    musl-dev

pecl$PHP_VERSION install imagick
echo "extension=imagick.so" > /etc/php$PHP_VERSION/conf.d/00_imagick.ini

# remove dev dependencies
apk del --no-cache imagemagick-dev \
    gcc \
    musl-dev \
    php$PHP_VERSION\-pear \
    php$PHP_VERSION\-dev

## Configure PHP
sed -i "s/upload_max_filesize.*/upload_max_filesize = 128M/g" /etc/php$PHP_VERSION/php.ini
sed -i "s/post_max_size.*/post_max_size = 128M/g" /etc/php$PHP_VERSION/php.ini
echo "error_log = /dev/stderr" >> /etc/php$PHP_VERSION/php.ini
echo "php_admin_value[upload_max_filesize] = 128M" >> /etc/php$PHP_VERSION/php.ini
echo "date.timezone = Europe/Zurich" >> /etc/php$PHP_VERSION/php.ini

# Add CLI symlink
ln -s /usr/bin/php$PHP_VERSION /usr/bin/php

# Install composer
wget -O - https://getcomposer.org/installer | php -- --quiet --2 --install-dir /usr/bin/ --filename composer
