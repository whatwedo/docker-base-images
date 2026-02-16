ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/nginx:$VERSION

# Add rootfs files
COPY ./shared/php/rootfs ./shared/php-fpm/rootfs ./rootfs /

# Install PHP and PHP-FPM (as root)
ENV PHP_VERSION=8.4
# The leading colon keeps each SAPI's own conf.d in the scan path
ENV PHP_INI_SCAN_DIR=:/etc/php/${PHP_VERSION}/conf.d
USER root
RUN PHP_VERSION="${PHP_VERSION}" /usr/local/sbin/install-php.sh && \
    rm /usr/local/sbin/install-php.sh && \
    PHP_VERSION="${PHP_VERSION}" /usr/local/sbin/install-php-fpm.sh && \
    rm /usr/local/sbin/install-php-fpm.sh

# Create PHP-FPM supervise directory and switch back to app user
RUN mkdir -p /etc/runit/runsvdir/default/php-fpm/supervise && \
    chown -R app:app /etc/runit/runsvdir/default/php-fpm
USER app
