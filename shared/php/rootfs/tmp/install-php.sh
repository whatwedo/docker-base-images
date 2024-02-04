#!/bin/sh

# Exit on error
set -ex

# Configuration
[ -z "$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1;

echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install PHP, composer and git with SSH support
apk add --no-cache php$PHP_VERSION \
    php$PHP_VERSION\-pecl-apcu \
    php$PHP_VERSION\-bcmath \
    php$PHP_VERSION\-calendar \
    php$PHP_VERSION\-common \
    php$PHP_VERSION\-ctype \
    php$PHP_VERSION\-curl \
    php$PHP_VERSION\-dev \
    php$PHP_VERSION\-dom \
    php$PHP_VERSION\-fileinfo \
    php$PHP_VERSION\-gd \
    php$PHP_VERSION\-iconv \
    php$PHP_VERSION\-intl \
    php$PHP_VERSION\-json \
    php$PHP_VERSION\-mbstring \
    php$PHP_VERSION\-mysqli \
    php$PHP_VERSION\-mysqlnd \
    php$PHP_VERSION\-opcache \
    php$PHP_VERSION\-openssl \
    php$PHP_VERSION\-pcntl \
    php$PHP_VERSION\-pdo \
    php$PHP_VERSION\-pdo_mysql \
    php$PHP_VERSION\-pdo_sqlite \
    php$PHP_VERSION\-pear \
    php$PHP_VERSION\-phar \
    php$PHP_VERSION\-posix \
    php$PHP_VERSION\-session \
    php$PHP_VERSION\-simplexml \
    php$PHP_VERSION\-soap \
    php$PHP_VERSION\-tokenizer \
    php$PHP_VERSION\-xml \
    php$PHP_VERSION\-xmlreader \
    php$PHP_VERSION\-xmlwriter \
    php$PHP_VERSION\-zip \
    php$PHP_VERSION\-zlib \
    git \
    openssh-client \
    libavif \
    libheif \
    libgomp \
    imagemagick \
    imagemagick-dev \
    gcc \
    musl-dev



# Imagick is installed from the archive because regular installation fails
# See: https://github.com/Imagick/imagick/issues/643#issuecomment-1834361716
# replace the routine with this command after PR has been merged:
#     pecl$PHP_VERSION install imagick 
cd /tmp
wget -O imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/3.7.0.tar.gz
tar xvfz imagick.tar.gz
cd imagick-3.7.0
phpize$PHP_VERSION
./configure --with-php-config=/usr/bin/php-config$PHP_VERSION --with-imagick
make
make install
cd /
rm -rf /tmp/imagick*

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
[ ! -f /usr/bin/php ] && ln -s /usr/bin/php$PHP_VERSION /usr/bin/php

# Install composer
wget -O - https://getcomposer.org/installer | php -- --quiet --2 --install-dir /usr/bin/ --filename composer
