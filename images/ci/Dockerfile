ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Install docker
RUN apk add --no-cache docker git

# Add rootfs files
COPY ./rootfs /
