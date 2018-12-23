# Define args
ARG BASE_IMAGE_TAG

################################################################################

# Golang container to build healthcheck
FROM golang:alpine AS healthcheck

# Install dependencies
RUN apk add --no-cache git && \
    go get -u github.com/soundcloud/go-runit/runit

# Add source code
ADD ./healthcheck /src

# Build app
RUN cd /src && go build -o healthcheck .

################################################################################

# Final image
ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Install runit
RUN apk add --no-cache runit && \
    mkdir -p /etc/service

# Add healthcheck
COPY --from=healthcheck /src/healthcheck /usr/local/bin
HEALTHCHECK --interval=60s --timeout=10s --start-period=60s \
    CMD /usr/local/bin/healthcheck

# Add rootfs files
COPY ./rootfs /

# Configure upstart script
RUN mkdir -p /etc/upstart
CMD ["/sbin/upstart"]
