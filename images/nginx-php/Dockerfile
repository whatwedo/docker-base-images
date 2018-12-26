ARG BASE_IMAGE_TAG
FROM whatwedo/nginx:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./rootfs ./shared/php/rootfs ./shared/php-fpm/rootfs /

# Install PHP and PHP-FPM
# TODO: Updated to 7.3 if php-memcached and FriendsOfPHP/PHP-CS-Fixer is available
ENV PHP_MAJOR_VERSION=7
ENV PHP_MINOR_VERSION=7.2
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh && \
    /tmp/install-php-fpm.sh && \
    rm /tmp/install-php-fpm.sh
