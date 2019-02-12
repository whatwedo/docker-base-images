ARG VERSION
FROM whatwedo/base:$VERSION

# Add rootfs files
COPY ./shared/php/rootfs /
RUN chmod 777 /tmp

# Install PHP
ENV PHP_MAJOR_VERSION=7
ENV PHP_MINOR_VERSION=7.3
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh
