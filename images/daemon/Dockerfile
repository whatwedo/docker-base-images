# Define args
ARG BASE_IMAGE_TAG

################################################################################

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
ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Install runit
RUN apk add --no-cache runit && \
    mkdir -p /etc/service

# Add runit-health
COPY --from=runit-health /src/runit-health /usr/local/bin

# Add rootfs files
COPY ./rootfs /

# Configure upstart script
RUN mkdir -p /etc/upstart
CMD ["/sbin/upstart"]
