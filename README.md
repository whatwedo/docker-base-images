[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v3.0/pipeline.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v3.0)

## Introduction & Versions
See README: https://github.com/whatwedo/docker-base-images/

## What's New in v3.0

v3.0 is a major release that migrates from Alpine Linux (musl) to **Debian 13 Trixie Slim (glibc)**. This resolves musl libc compatibility issues and provides better binary compatibility for third-party software.

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and [MIGRATION-v3.md](MIGRATION-v3.md) for a step-by-step migration guide from v2.x.

### Key Changes

- **Base OS**: Debian 13 (Trixie) Slim with glibc
- **Service user**: `app` (UID 10000 / GID 10001) — all services run as this user
- **PHP 8.4** via [Sury PPA](https://packages.sury.org/php/)
- **Node.js 22.x LTS** via [NodeSource](https://deb.nodesource.com/)
- **No privilege escalation tools** — use `docker exec --user root` instead
- **Service directory**: `/etc/runit/runsvdir/default/` (not `/etc/service/`)

## Images

| Name | Description |
|---|---|
| `whatwedo/base` | Base image with runit, goss health checks, and app user |
| `whatwedo/nginx` | nginx web server running as app user |
| `whatwedo/nginx-php` | nginx + PHP-FPM 8.4 with unix socket |
| `whatwedo/php` | PHP 8.4 CLI with Composer 2 |
| `whatwedo/symfony` | Symfony-optimized nginx + PHP-FPM |
| `whatwedo/nodejs` | Node.js 22.x LTS with npm |

## Usage

```
docker run whatwedo/base:v3.0
```

## Directory/File Layout

| Folder | Description |
|---|---|
| `images` | Dockerfiles, rootfs overlays, and per-image configuration |
| `shared` | Shared configuration templates copied into images at build time |
| `build_order` | Defines the image build sequence |
| `build.sh` | Build and test script for single or all images |

## Installed Software

### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. Services are managed in `/etc/runit/runsvdir/default/`. The `runit-health` tool monitors all services and reports status to goss.

### goss

[goss](https://github.com/aelsabbahy/goss) validates server configuration and health. It runs automatically via Docker HEALTHCHECK every 30 seconds. Add custom checks in `/etc/goss/conf.d/`.

For Kubernetes, use `goss validate` as a liveness/readiness probe.

### apt-install

Convenience helper for **derived images** (your own Dockerfiles built on top of these). It wraps `apt-get update`, `apt-get install -y --no-install-recommends`, and cache cleanup into a single command:

```dockerfile
RUN apt-install imagemagick ffmpeg
```

### nginx

(installed in `whatwedo/nginx`, `whatwedo/nginx-php`, `whatwedo/symfony`)

[nginx](https://www.nginx.com/) with modular include-based configuration. Place your site in `/var/www`. Configuration directories:

- `/etc/nginx/directive.d/` — top-level directives
- `/etc/nginx/http.d/` — HTTP block settings
- `/etc/nginx/server.d/` — server blocks
- `/etc/nginx/server.d/default.d/` — default server location blocks

**Security headers** (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`) are set at the `http` level in `/etc/nginx/http.d/11-defaults.conf`. Mind nginx's `add_header` inheritance: if you add your own `add_header` inside a `server` or `location` block, nginx **replaces** the inherited headers for that block and silently drops the security headers. Re-declare them in any block where you set headers of your own.

**Trusted proxies / real client IP**: `/etc/nginx/http.d/05-real-ip.conf` trusts the `X-Forwarded-For` header from all private network ranges (RFC1918 + `fc00::/7`) by default, assuming the container runs behind a trusted reverse proxy. **If the container is exposed directly to the internet, override this file** — otherwise clients can spoof their source IP via `X-Forwarded-For`.

### PHP

(installed in `whatwedo/php`, `whatwedo/nginx-php`, `whatwedo/symfony`)

PHP 8.4 from [Sury PPA](https://packages.sury.org/php/) with the following modules:

apcu, bcmath, calendar, common, curl, dom, gd, iconv, imagick, intl, mbstring, mariadb (mysql), opcache, pcntl, pdo, pdo-mariadb (pdo-mysql), pdo-sqlite, phar, posix, readline, simplexml, soap, tokenizer, xml, xmlreader, xmlwriter, zip

PHP from the Sury PPA ships with additional compiled-in modules such as `sodium`. Run `php -m` inside the container to see the full list.

#### Custom Settings

| Key | Value |
|---|---|
| upload_max_filesize | 128M |
| post_max_size | 128M |
| memory_limit (FPM) | 128M |
| pm.max_children | 32 |
| pm.start_servers | 2 |
| pm.min_spare_servers | 2 |
| pm.max_spare_servers | 8 |
| date.timezone | Europe/Zurich |

#### PHP Configuration Paths

- Shared custom configs (CLI + FPM): `/etc/php/8.4/conf.d/`
- CLI config: `/etc/php/8.4/cli/php.ini`
- CLI custom configs: `/etc/php/8.4/cli/conf.d/`
- FPM config: `/etc/php/8.4/fpm/php-fpm.conf`
- FPM pool: `/etc/php/8.4/fpm/pool.d/www.conf`
- FPM custom configs: `/etc/php/8.4/fpm/conf.d/`

The shared `conf.d/` is scanned by both CLI and FPM via `PHP_INI_SCAN_DIR`. Use it for configs that should apply to both SAPIs (e.g. xdebug). SAPI-specific configs go into the respective `cli/conf.d/` or `fpm/conf.d/`.

### Node.js

(installed in `whatwedo/nodejs`)

Node.js 22.x LTS from [NodeSource](https://deb.nodesource.com/) with npm.

The installation logic lives in the helper script `/usr/local/sbin/install-nodejs.sh`, which ships in every image (it is part of the base image). Images on the PHP/Symfony chain that need Node.js can install it at build time without basing off `whatwedo/nodejs`:

```dockerfile
FROM whatwedo/symfony:v3.0
USER root
RUN /usr/local/sbin/install-nodejs.sh
USER app
```

## Upstart

The default command (`CMD`) is `/usr/sbin/upstart`. It runs all scripts in `/etc/upstart/` alphabetically at container startup, then starts runit service supervision.

Example — fix file permissions at startup:

```bash
#!/bin/sh
# /etc/upstart/10-permissions.sh
chown -R app:app /var/www/var/storage
```

## Container Access

```bash
# Enter container as app user (default)
docker exec -it container-name bash

# Enter container as root
docker exec -it --user root container-name bash
```

## Exposed Ports

| Image | Port |
|---|---|
| `whatwedo/nginx`, `whatwedo/nginx-php`, `whatwedo/symfony` | 80 |

## Migrating from v2.x

See [MIGRATION-v3.md](MIGRATION-v3.md) for a complete migration guide.

## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.

## License

This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.5/LICENSE.
