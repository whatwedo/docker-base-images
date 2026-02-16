ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

# Install nginx and clean Debian default configs
USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/nginx/sites-enabled/* \
    && rm -rf /etc/nginx/sites-available/* \
    && rm -rf /etc/nginx/conf.d/* \
    && rm -f /etc/nginx/nginx.conf \
    && mkdir -p /var/www /var/log/nginx /var/lib/nginx \
    && chown -R app:app /var/www /var/log/nginx /var/lib/nginx

# Add rootfs files
COPY ./shared/nginx/rootfs /
COPY ./rootfs /

# Create runit supervise directories for app user
RUN mkdir -p /etc/runit/runsvdir/default/nginx/supervise && \
    chown -R app:app /etc/runit/runsvdir/default

WORKDIR /var/www
EXPOSE 8080
HEALTHCHECK --retries=5 --interval=30s --timeout=10s --start-period=30s \
    CMD goss validate
USER app
