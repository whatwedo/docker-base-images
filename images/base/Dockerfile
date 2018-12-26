# Golang container to build runit-health
FROM golang:alpine AS runit-health

# Install dependencies
RUN apk add --no-cache git && \
    go get -u github.com/soundcloud/go-runit/runit

# Add source code
ADD ./runit-health /src

# Build app
RUN cd /src && go build -o runit-health .

################################################################################

# Final image
FROM alpine:3.8

# Maintainer as instruction (deprecated)
MAINTAINER whatwedo GmbH <welove@whatwedo.ch>

# Maintainer as label
LABEL maintainer="whatwedo GmbH <welove@whatwedo.ch>"

# Install runit
RUN apk add --no-cache runit && \
    mkdir -p /etc/service

# Add runit-health
COPY --from=runit-health /src/runit-health /usr/local/bin

# Install goss
RUN apk add --no-cache --virtual .build-deps curl && \
    curl -fsSL https://goss.rocks/install | sh && \
    apk del --no-cache .build-deps
ENV GOSS_FILE=/etc/goss/goss.yaml

# Add rootfs files
COPY ./rootfs /

# Set healthcheck
HEALTHCHECK --interval=60s --timeout=10s --start-period=60s \
    CMD goss validate

# Configure upstart script
RUN mkdir -p /etc/upstart
CMD ["/sbin/upstart"]
