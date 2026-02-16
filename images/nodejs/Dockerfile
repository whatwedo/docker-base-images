ARG VERSION=v3.0
ARG REGISTRY=whatwedo
FROM ${REGISTRY}/base:$VERSION

COPY ./rootfs /

# Add NodeSource GPG key and repository, then install Node.js 22.x LTS
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
       gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

USER app
