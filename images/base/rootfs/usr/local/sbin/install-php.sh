#!/bin/sh
set -ex
export DEBIAN_FRONTEND=noninteractive

[ -z "$PHP_VERSION" ] && echo "PHP_VERSION is not set" && exit 1
printf '%s\n' "$PHP_VERSION" | grep -Eq '^[0-9]+\.[0-9]+$' || {
    echo "PHP_VERSION must be a major.minor version (for example 8.4)" >&2
    exit 1
}

# Sury signing key — pinned so a compromised or redirected download fails the build
SURY_KEY_FPR="15058500A0235D97F5D10063B188E2B695BD4743"

# Add Sury PHP repository
apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    lsb-release
/usr/local/sbin/import-apt-key.sh \
    https://packages.sury.org/php/apt.gpg \
    "$SURY_KEY_FPR" \
    /etc/apt/keyrings/sury-php.gpg
echo "deb [signed-by=/etc/apt/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list

# Install PHP and extensions
# Note: opcache, pcntl, pdo, phar, posix, simplexml, tokenizer, xmlreader, xmlwriter
# are typically included in php-common and don't have separate packages
# Imagick delegates PDF rendering to Ghostscript, even without the ImageMagick CLI.
apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    ghostscript \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP for both SAPIs via the shared conf.d (see PHP_INI_SCAN_DIR).
# A dedicated file instead of patching php.ini: overriding a directive only ever
# means dropping another file into conf.d, and nothing depends on Debian's
# php.ini shipping a given directive uncommented.
mkdir -p "/etc/php/${PHP_VERSION}/conf.d"
cat > "/etc/php/${PHP_VERSION}/conf.d/99-whatwedo.ini" <<'INI'
upload_max_filesize = 128M
post_max_size = 128M
date.timezone = ${TZ}
expose_php = Off
error_log = /dev/stderr
INI

# Ensure php symlink
[ ! -f /usr/bin/php ] && ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# Install Composer (verify installer against the official SHA-384 signature)
EXPECTED_CHECKSUM="$(curl -sS https://composer.github.io/installer.sig)"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo "ERROR: Invalid composer installer checksum" >&2
    rm -f /tmp/composer-setup.php
    exit 1
fi
php /tmp/composer-setup.php --quiet --2 --install-dir=/usr/bin/ --filename=composer
rm -f /tmp/composer-setup.php
