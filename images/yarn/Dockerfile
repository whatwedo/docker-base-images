ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Add rootfs files
COPY ./rootfs /

# Install node
RUN apk add --no-cache yarn
