FROM alpine:latest

# Maintainer as instruction (deprecated)
MAINTAINER whatwedo GmbH <welove@whatwedo.ch>

# Maintainer as label
LABEL maintainer="whatwedo GmbH <welove@whatwedo.ch>"

# Install goss
RUN apk add --no-cache --virtual .build-deps curl && \
    curl -fsSL https://goss.rocks/install | sh && \
    apk del .build-deps
ENV GOSS_FILE=/etc/goss/goss.yaml

# Add rootfs files
COPY ./rootfs /

# Set healthcheck
HEALTHCHECK --interval=60s --timeout=10s --start-period=60s \
    CMD goss validate
