ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

ENV PHP_VERSION=8.4 \
    PHP_MEMORY_LIMIT=-1 \
    PHP_INI_SCAN_DIR=:/etc/php/8.4/conf.d \
    XDG_CONFIG_HOME=/var/lib/frankenphp/config \
    XDG_DATA_HOME=/var/lib/frankenphp/data \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_DIR=/etc/ssl/certs

USER root
COPY ./shared/php/rootfs /
COPY ./install-frankenphp.sh /tmp/install-frankenphp.sh
RUN /tmp/install-frankenphp.sh && \
    rm /tmp/install-frankenphp.sh /usr/local/sbin/install-php.sh

COPY ./rootfs /
RUN mkdir -p /var/www/public /var/lib/frankenphp/config /var/lib/frankenphp/data \
        /etc/runit/runsvdir/default/frankenphp/supervise && \
    chown -R app:app /var/www /var/lib/frankenphp \
        /etc/runit/runsvdir/default/frankenphp/supervise

WORKDIR /var/www
EXPOSE 8080
HEALTHCHECK --retries=5 --interval=30s --timeout=10s --start-period=30s \
    CMD goss validate
USER app
