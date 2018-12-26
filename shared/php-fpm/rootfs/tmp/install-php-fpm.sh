#!/bin/sh

# Exit on error
set -ex

# Configuration
[ -z "$PHP_MAJOR_VERSION" ] && echo "PHP_MAJOR_VERSION is not set" && exit 1;
[ -z "$PHP_MINOR_VERSION" ] && echo "PHP_MINOR_VERSION is not set" && exit 1;

# Install PHP-FPM
apk add --no-cache php-fpm@php

# Configure PHP-FPM
sed -i s,^listen\ =\ .*,listen\ =\ /var/run/php-fpm.sock,g /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "listen.owner = nginx" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "listen.group = nginx" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_admin_value[post_max_size] = 50M" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_flag[display_errors] = off" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_admin_flag[log_errors] = on" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_admin_value[error_log] = /dev/sdterr" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "php_flag[expose_php] = Off" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "clear_env = no" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
echo "catch_workers_output = yes" >> /etc/php$PHP_MAJOR_VERSION/php-fpm.d/www.conf
