ARG VERSION
FROM whatwedo/nginx:$VERSION

# Add rootfs files
COPY ./rootfs ./shared/php/rootfs ./shared/php-fpm/rootfs /
RUN chmod 777 /tmp

ENV PHP_VERSION=7
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh && \
    /tmp/install-php-fpm.sh && \
    rm /tmp/install-php-fpm.sh
