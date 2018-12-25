ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./shared/php/rootfs /

# Install php
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh
