#!/bin/sh
set -ex
export DEBIAN_FRONTEND=noninteractive

# NodeSource signing key — pinned so a compromised or redirected download fails the build
NODESOURCE_KEY_FPR="6F71F525282841EEDAF851B42F59B5F99B1BE0B4"
NPM_VERSION="10.9.9"
# Security floor for the tar release npm bundles; raise it when a new tar advisory lands
NPM_TAR_MIN_VERSION="7.5.19"

# Add NodeSource GPG key and repository, then install Node.js 22.x LTS
/usr/local/sbin/import-apt-key.sh \
    https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    "$NODESOURCE_KEY_FPR" \
    /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y --no-install-recommends nodejs

npm install --global --no-audit --no-fund "npm@${NPM_VERSION}"
test "$(npm --version)" = "$NPM_VERSION"

NPM_TAR_VERSION="$(node -p "require('$(npm root --global)/npm/node_modules/tar/package.json').version")"
dpkg --compare-versions "$NPM_TAR_VERSION" ge "$NPM_TAR_MIN_VERSION" || {
    echo "npm bundles tar $NPM_TAR_VERSION; expected at least $NPM_TAR_MIN_VERSION" >&2
    exit 1
}

npm cache clean --force
rm -rf /var/lib/apt/lists/*
