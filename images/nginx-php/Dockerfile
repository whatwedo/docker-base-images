ARG VERSION
FROM whatwedo/nginx:$VERSION

# Add rootfs files
COPY ./rootfs ./shared/php/rootfs ./shared/php-fpm/rootfs /
RUN chmod 777 /tmp

# Install PHP and PHP-FPM
ENV PHP_MAJOR_VERSION=7
ENV PHP_MINOR_VERSION=7.3
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh && \
    /tmp/install-php-fpm.sh && \
    rm /tmp/install-php-fpm.sh
