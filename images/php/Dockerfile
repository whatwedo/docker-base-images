ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./shared/php/rootfs /

# Install PHP
ENV PHP_MAJOR_VERSION=7
ENV PHP_MINOR_VERSION=7.3
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh
