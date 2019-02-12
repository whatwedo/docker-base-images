ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./rootfs /

# Install yarn
RUN apk add --no-cache yarn
