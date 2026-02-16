# Build Go-based runtime tools with the current patched toolchain. goss is built
# from source, so the checksum database has to stay on to verify every module.
FROM golang:1.26 AS go-tools
ARG GOSS_VERSION=v0.4.10
RUN mkdir -p /src && \
    { [ "$(go env GOSUMDB)" != "off" ] || { echo "ERROR: GOSUMDB is disabled" >&2; exit 1; }; } && \
    GOBIN=/src CGO_ENABLED=0 go install -trimpath -buildvcs=false \
        -ldflags "-X github.com/goss-org/goss/util.Version=${GOSS_VERSION} -s -w" \
        "github.com/goss-org/goss/cmd/goss@${GOSS_VERSION}" && \
    [ "$(/src/goss --version)" = "goss version ${GOSS_VERSION}" ]

ADD ./runit-health /src
RUN cd /src && go build -o runit-health .

# Final image
FROM debian:trixie-slim

ARG VERSION
ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive
ENV BASE_IMAGE_VERSION=${VERSION:-unknown} \
    BUILD_DATE=${BUILD_DATE:-unknown} \
    TZ=Europe/Zurich

LABEL maintainer="whatwedo GmbH <welove@whatwedo.ch>" \
    org.opencontainers.image.title="whatwedo/docker-base-images" \
    org.opencontainers.image.url="https://github.com/whatwedo/docker-base-images" \
    org.opencontainers.image.source="https://github.com/whatwedo/docker-base-images" \
    org.opencontainers.image.vendor="whatwedo GmbH" \
    org.opencontainers.image.version=$VERSION

# Install base dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    bind9-dnsutils \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    iputils-ping \
    make \
    openssh-client \
    runit \
    && rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/service

# Add runtime tools
COPY --from=go-tools /src/runit-health /src/goss /usr/local/bin/

# Create app user/group with UID 10000 / GID 10001
RUN groupadd -g 10001 app && \
    useradd -u 10000 -g app -m -s /bin/bash app

ENV GOSS_FILE=/etc/goss/goss.yaml

# Add rootfs files
COPY ./rootfs /

# Configure MOTD
RUN chmod +x /etc/update-motd.d/* && \
    echo 'run-parts /etc/update-motd.d/ 2>/dev/null' >> /etc/bash.bashrc

# Configure upstart
RUN mkdir -p /etc/upstart
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/upstart"]

# Run as app — derived images have to open a USER root block for build steps
USER app
