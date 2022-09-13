# Golang container to build runit-health
FROM golang:1.17-alpine3.16 AS runit-health

# Install dependencies
RUN apk add --no-cache git && \
    go env -w GO111MODULE=off && \
    go get -u github.com/soundcloud/go-runit/runit

# Add source code
ADD ./runit-health /src

# Build app
RUN cd /src && go build -o runit-health .

################################################################################

# Final image
FROM alpine:3.16

# Set labels
ARG VERSION
LABEL maintainer="whatwedo GmbH <welove@whatwedo.ch>" \
    org.label-schema.name="whatwedo/docker-base-images" \
    org.label-schema.url="https://github.com/whatwedo/docker-base-images" \
    org.label-schema.vcs-url="https://github.com/whatwedo/docker-base-images" \
    org.label-schema.vendor="whatwedo GmbH" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

# Install base dependencies
RUN apk add --no-cache ca-certificates gnu-libiconv make doas

# set default libiconv from gnu
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install runit
RUN apk add --no-cache runit && \
    mkdir -p /etc/service

# Add runit-health
COPY --from=runit-health /src/runit-health /usr/local/bin

# Install goss
RUN apk add --no-cache --virtual .build-deps curl && \
    curl -fsSL https://goss.rocks/install | sh && \
    apk del --no-cache .build-deps
ENV GOSS_FILE=/etc/goss/goss.yaml

# configure default timezone
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" > /etc/timezone && \
    apk del tzdata

# Add rootfs files
COPY ./rootfs /

# Set health check
HEALTHCHECK --retries=5 --interval=30s --timeout=10s --start-period=30s \
    CMD goss validate

# Configure upstart script
RUN mkdir -p /etc/upstart
CMD ["/sbin/upstart"]
