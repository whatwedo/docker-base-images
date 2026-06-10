ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

# Add rootfs files
COPY ./shared/php/rootfs /

# Install PHP (as root)
ENV PHP_VERSION=8.4
ENV PHP_INI_SCAN_DIR=/etc/php/${PHP_VERSION}/conf.d:/etc/php/${PHP_VERSION}/cli/conf.d
ENV COMPOSER_ALLOW_SUPERUSER=1
USER root
RUN /usr/local/sbin/install-php.sh && rm /usr/local/sbin/install-php.sh

# Switch to app user
USER app
