# Define args
ARG BASE_IMAGE_TAG

################################################################################

# Golang container to build healthcheck
FROM golang:alpine AS healthcheck

# Install dependencies
RUN apk add --no-cache git


################################################################################

# Final image
ARG BASE_IMAGE_TAG
FROM whatwedo/base:$BASE_IMAGE_TAG

# Install runit
RUN apk add --no-cache runit && \
    mkdir -p /etc/service

# Add files
COPY ./files /

# Configure upstart script
RUN mkdir -p /etc/upstart
CMD ["/sbin/upstart"]
