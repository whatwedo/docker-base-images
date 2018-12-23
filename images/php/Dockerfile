ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Install php
COPY ./shared/install-php.sh /tmp
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh
