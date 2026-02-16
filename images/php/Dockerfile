ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

# Add rootfs files
COPY ./shared/php/rootfs /

# Install PHP (as root)
ENV PHP_VERSION=8.4
# The leading colon keeps each SAPI's own conf.d in the scan path
ENV PHP_INI_SCAN_DIR=:/etc/php/${PHP_VERSION}/conf.d
USER root
RUN PHP_VERSION="${PHP_VERSION}" /usr/local/sbin/install-php.sh && \
    rm /usr/local/sbin/install-php.sh

# Switch to app user
HEALTHCHECK NONE
USER app
