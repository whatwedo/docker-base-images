ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

COPY ./rootfs /

USER root
# Install Node.js via the shared helper script (inherited from the base image)
RUN /usr/local/sbin/install-nodejs.sh

HEALTHCHECK NONE
USER app
