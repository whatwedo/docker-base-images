ARG BASE_IMAGE_TAG
FROM whatwedo/nginx:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./rootfs ./shared/php/rootfs ./shared/php-fpm/rootfs /

# Install PHP and PHP-FPM
ENV PHP_MAJOR_VERSION=7
ENV PHP_MINOR_VERSION=7.3
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh && \
    /tmp/install-php-fpm.sh && \
    rm /tmp/install-php-fpm.sh
