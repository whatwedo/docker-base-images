ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

COPY ./rootfs /

# Install Node.js via the shared helper script (inherited from the base image)
RUN /usr/local/sbin/install-nodejs.sh

USER app
