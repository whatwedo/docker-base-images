# Build runit-health
FROM golang:1.26 AS runit-health
ADD ./runit-health /src
RUN cd /src && go build -o runit-health .

# Final image
FROM debian:trixie-slim

ARG VERSION
ARG BUILD_DATE
ENV DEBIAN_FRONTEND=noninteractive \
    BASE_IMAGE_VERSION=${VERSION:-unknown} \
    BUILD_DATE=${BUILD_DATE:-unknown} \
    TZ=Europe/Zurich

LABEL maintainer="whatwedo GmbH <welove@whatwedo.ch>" \
    org.opencontainers.image.title="whatwedo/docker-base-images" \
    org.opencontainers.image.url="https://github.com/whatwedo/docker-base-images" \
    org.opencontainers.image.source="https://github.com/whatwedo/docker-base-images" \
    org.opencontainers.image.vendor="whatwedo GmbH" \
    org.opencontainers.image.version=$VERSION

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Add runit-health
COPY --from=runit-health /src/runit-health /usr/local/bin

# Create app user/group with UID 10000 / GID 10001
RUN groupadd -g 10001 app && \
    useradd -u 10000 -g app -m -s /bin/bash app

# Install goss (pinned version, checksum-verified)
ARG GOSS_VERSION=v0.4.9
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) GOSS_SHA256="87dd36cfa1b8b50554e6e2ca29168272e26755b19ba5438341f7c66b36decc19" ;; \
        arm64) GOSS_SHA256="14fd24ac08236559f4809e6a627792d1b947ed98654bba1662ef1d6122d77e18" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/goss "https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH}" && \
    echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - && \
    chmod +rx /usr/local/bin/goss
ENV GOSS_FILE=/etc/goss/goss.yaml

# Add rootfs files
COPY ./rootfs /

# Configure MOTD
RUN chmod +x /etc/update-motd.d/* && \
    echo 'run-parts /etc/update-motd.d/ 2>/dev/null' >> /etc/bash.bashrc

# Set health check
HEALTHCHECK --retries=5 --interval=30s --timeout=10s --start-period=30s \
    CMD goss validate

# Configure upstart
RUN mkdir -p /etc/upstart
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/upstart"]
