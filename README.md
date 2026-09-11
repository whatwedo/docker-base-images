[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://github.com/whatwedo/docker-base-images/actions/workflows/images.yml/badge.svg?branch=v3.0)](https://github.com/whatwedo/docker-base-images/actions/workflows/images.yml?query=branch%3Av3.0)

## Introduction & Versions
See README: https://github.com/whatwedo/docker-base-images/

## What's New in v3.0

v3.0 is a major release that migrates from Alpine Linux (musl) to **Debian 13 Trixie Slim (glibc)**. This resolves musl libc compatibility issues and provides better binary compatibility for third-party software.

See [CHANGELOG.md](https://github.com/whatwedo/docker-base-images/blob/v3.0/CHANGELOG.md) for a detailed list of changes and [MIGRATION-v3.md](https://github.com/whatwedo/docker-base-images/blob/v3.0/MIGRATION-v3.md) for a step-by-step migration guide from v2.10 and v2.11.

### Key Changes

- **Base OS**: Debian 13 (Trixie) Slim with glibc
- **Service user**: `app` (UID 10000 / GID 10001) — all services run as this user
- **nginx port**: `8080` instead of `80` — an unprivileged port needs no capabilities; update port mappings, probes and ingress
- **PHP 8.4** via [Sury's Debian APT repository](https://packages.sury.org/php/) (v2.11 used PHP 8.5)
- **Node.js 22.x LTS** via [NodeSource](https://deb.nodesource.com/) (v2.11 used Node.js 24.x)
- **npm 10.x** is pinned and verified; Yarn must be installed explicitly if the project requires it
- **No privilege escalation tools** — use `docker exec --user root` instead
- **Service directory**: `/etc/runit/runsvdir/default/` (not `/etc/service/`)

## Images

| Name | Description |
|---|---|
| `whatwedo/base` | Base image with runit, goss, and app user |
| `whatwedo/nginx` | nginx web server running as app user |
| `whatwedo/nginx-php` | nginx + PHP-FPM 8.4 with unix socket |
| `whatwedo/php` | PHP 8.4 CLI with Composer 2 |
| `whatwedo/symfony` | Symfony-optimized nginx + PHP-FPM |
| `whatwedo/nodejs` | Node.js 22.x LTS with npm |
| `whatwedo/frankenphp` | FrankenPHP with PHP 8.4 ZTS, classic and worker modes |

## Registries

Every image is built and tested in GitHub Actions, published to ghcr.io and copied to the whatwedo registry and Docker Hub, so the digests are identical everywhere. Pick whichever one your environment reaches best.

| Registry | Image prefix | Notes |
|---|---|---|
| whatwedo (primary) | `registry.whatwedo.ch/whatwedo/docker-base-images/<image>` | Used by whatwedo projects |
| GitHub Container Registry | `ghcr.io/whatwedo/<image>` | Build registry, v3 and newer only, no pull rate limit |
| Docker Hub | `whatwedo/<image>` | Mirror, subject to Docker Hub rate limits |

The ghcr.io mirror was introduced with v3 — images for v1.x and v2.x are only available from the whatwedo registry and Docker Hub.

```
docker pull registry.whatwedo.ch/whatwedo/docker-base-images/base:v3.0
docker pull ghcr.io/whatwedo/base:v3.0
docker pull whatwedo/base:v3.0
```

## Usage

```
docker run whatwedo/base:v3.0
```

### Runtime Hardening

The images run as `app` (UID 10000 / GID 10001) and do not require Linux capabilities. Capability drops and privilege-escalation controls are runtime settings, however; a Dockerfile cannot enable them for the deployment that consumes the image.

```bash
docker run --cap-drop=ALL --security-opt=no-new-privileges whatwedo/base:v3.0
```

For Kubernetes, set the controls explicitly. Supplying the numeric UID also lets `runAsNonRoot` verify the named image user without relying on name resolution:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10000
  runAsGroup: 10001
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
```

## Directory/File Layout

| Folder | Description |
|---|---|
| `images` | Dockerfiles, rootfs overlays, and per-image configuration |
| `shared` | Shared configuration templates copied into images at build time |
| `images.conf` | Build order, health check contract and test suites per image |
| `build.sh` | Builds, tests and publishes single or all images |
| `tests` | Test suites the images have to pass |
| `.github/workflows` | Pipeline that tests every image on amd64 and arm64 before publishing |

## Installed Software

### FrankenPHP

`whatwedo/frankenphp` derives from our Debian base and runs FrankenPHP under runit as `app` (UID 10000 / GID 10001). It serves HTTP on port **8080** with `/var/www/public` as its default document root. TLS terminates at the reverse proxy. The default mode starts a fresh PHP request for each HTTP request.

```bash
docker run --rm --cap-drop=ALL --security-opt=no-new-privileges \
    -p 8080:8080 -v "$PWD:/var/www:ro" whatwedo/frankenphp:v3.0
```

PHP 8.4 **ZTS** and FrankenPHP come from the [upstream maintainers' Debian repository](https://frankenphp.dev/docs/), selected specifically for PHP 8.4 and checked against a pinned signing-key fingerprint. Composer 2, the extensions listed below, and Ghostscript are included. The same PHP runtime supports the real `php` CLI and HTTP requests; Composer `@php` scripts work normally.

| Setting | Default / purpose |
|---|---|
| `FRANKENPHP_DOCUMENT_ROOT` | `/var/www/public` |
| `FRANKENPHP_NUM_THREADS` | `4` initial PHP threads |
| `FRANKENPHP_MAX_THREADS` | `16` maximum PHP threads |
| `FRANKENPHP_CONFIG` | Optional directives inside the global `frankenphp` block, e.g. worker configuration |
| `FRANKENPHP_TRUSTED_PROXIES` | Space-separated private CIDRs: `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fc00::/7` |
| `SHUTDOWN_TIMEOUT` | `8` seconds to finish active requests |

Only a trusted immediate proxy peer may assert the client IP and external HTTPS scheme. Untrusted forwarded headers are removed before PHP handles the request. The trusted scheme becomes `HTTPS`, `HTTP_SCHEME` and `SERVER_PORT`, including support for the legacy `X-Use-Https` header. When exposed directly, restrict `FRANKENPHP_TRUSTED_PROXIES` to the actual proxy addresses.

`/etc/frankenphp/Caddyfile` is only a frame; the admin API listens on container loopback at `127.0.0.1:2019`. Like nginx's `http.d/` and `server.d/default.d/`, the actual configuration lives in numbered drop-in files that Caddy imports in name order:

| Directory | Scope | Shipped files |
|---|---|---|
| `/etc/frankenphp/frankenphp.d/` | Global `frankenphp {}` block | `10-threads`, `90-config` (`FRANKENPHP_CONFIG`) |
| `/etc/frankenphp/site.d/` | Site block, ordered by Caddy's directive order | `10-root`, `20-log`, `30-headers`, `40-encode` |
| `/etc/frankenphp/route.d/` | `route {}` inside the site block, executed in file order | `10-health`, `20-trusted-proxy`, `30-hidden-files`, `35-source-files`, `90-php-server` |

A project adds a file, replaces one by the same name, or removes one in its Dockerfile; the base files it does not touch keep working, including later fixes. Matchers and handlers that must run before the PHP front controller (extra 404s, cache headers, ping endpoints) go into `route.d/` between `35` and `90`. An application with its own routing replaces `90-php-server.conf`:

```dockerfile
FROM whatwedo/frankenphp:v3.0
COPY docker/frankenphp/route.d/50-private-files.conf /etc/frankenphp/route.d/
COPY docker/frankenphp/route.d/90-api.conf /etc/frankenphp/route.d/90-php-server.conf
RUN frankenphp validate --config /etc/frankenphp/Caddyfile --adapter caddyfile
```

`/frankenphp-health` executes a bundled PHP script independently of the application and is used by the image health check. Hidden paths, PHP source variants, backups and dumps return 404. Existing lowercase `.php` files execute; missing application paths fall back to `index.php`.

Additional PHP configuration goes in `/etc/php/8.4/conf.d/*.ini`, shared by CLI and FrankenPHP. The ZTS packages also load `/etc/php-zts/conf.d`. Add extensions from the ZTS repository in a root build phase, for example:

```dockerfile
FROM whatwedo/frankenphp:v3.0
USER root
RUN apt-install php-zts-redis
USER app
COPY . /var/www
```

Use `php-zts-*` extensions in this image; Sury's `php8.4-*` extensions use a different ABI. The packaged Imagick build disables OpenMP, avoiding the [threading conflict documented by FrankenPHP](https://frankenphp.dev/docs/known-issues/).

For an application with a [FrankenPHP-compatible worker entrypoint](https://frankenphp.dev/docs/worker/), enable workers explicitly:

```dockerfile
ENV FRANKENPHP_CONFIG="worker /var/www/public/index.php 2"
```

Keep some PHP threads available for ordinary requests and the health endpoint. Worker applications remain in memory between requests and must reset application state themselves; an ordinary `index.php` is not automatically a worker. Both classic and worker modes are tested for graceful shutdown, including an active request during `docker stop`.

### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. Services are managed in `/etc/runit/runsvdir/default/`. The `runit-health` tool monitors all services and reports status to goss.

**Custom services**: keep `run` executable in Git and copy the runit overlay with `--chown=app:app`; `runsv` creates `supervise/` automatically in the writable service directory. To keep service scripts root-owned, create only an `app`-owned `supervise/` directory at build time. See the [Dockerfile examples in the migration guide](https://github.com/whatwedo/docker-base-images/blob/v3.0/MIGRATION-v3.md#5-move-custom-services).

**Graceful shutdown**: `SIGTERM` drains the running services before runit goes away — nginx stops accepting connections and finishes the requests it has already handed to PHP-FPM, then PHP-FPM lets its workers complete. `SHUTDOWN_TIMEOUT` (default `8`, in seconds) is the budget shared by all services. Raise it together with the runtime's own grace period — Docker's `--stop-timeout` or Kubernetes' `terminationGracePeriodSeconds` — otherwise the runtime sends `SIGKILL` first.

### goss

[goss](https://github.com/goss-org/goss) validates image configuration and service health. The nginx, nginx-php, and symfony images run it automatically via Docker HEALTHCHECK every 30 seconds. The generic base, PHP CLI, and Node.js images deliberately do not inherit a supervisor-specific health check, because consumers commonly replace their default command. Add application-specific checks in `/etc/goss/conf.d/` and define a HEALTHCHECK in the derived image when needed.

For Kubernetes, use `goss validate` as a liveness/readiness probe.

### apt-install

Convenience helper for **derived images** (your own Dockerfiles built on top of these). It wraps `apt-get update`, `apt-get install -y --no-install-recommends`, and cache cleanup into a single command:

```dockerfile
USER root
RUN apt-install imagemagick ffmpeg
USER app
```

### nginx

(installed in `whatwedo/nginx`, `whatwedo/nginx-php`, `whatwedo/symfony`)

[nginx](https://www.nginx.com/) with modular include-based configuration. Place your site in `/var/www`. Configuration directories:

- `/etc/nginx/directive.d/` — top-level directives
- `/etc/nginx/http.d/` — HTTP block settings
- `/etc/nginx/server.d/` — server blocks
- `/etc/nginx/server.d/default.d/` — default server location blocks

**Port**: nginx listens on **8080** as the unprivileged `app` user without requiring a capability to bind the port. Map the port on the outside (`-p 80:8080`, `containerPort: 8080`). PHP sees `SERVER_PORT` 80, or 443 when a trusted proxy peer signals HTTPS as described below.

**Expected startup messages**: nginx's warning about the ignored `user` directive and FPM's notices about ignored pool `user`/`group` directives are expected when starting as `app`. These directives exist for whatwedo/dde, which starts as root and rewrites the worker identities.

**Security headers** (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`) are set at the `http` level in `/etc/nginx/http.d/11-defaults.conf`. Mind nginx's `add_header` inheritance: if you add your own `add_header` inside a `server` or `location` block, nginx **replaces** the inherited headers for that block and silently drops the security headers. Re-declare them in any block where you set headers of your own.

**Trusted proxies / real client IP**: `/etc/nginx/http.d/05-real-ip.conf` trusts `X-Forwarded-For` from private network peers (RFC1918 + `fc00::/7`) by default, assuming those peers are trusted reverse proxies. Narrow both proxy lists to your actual proxies if untrusted clients can reach the container through those ranges, including through NAT. `X-Real-IP` is no longer evaluated for PHP's `REMOTE_ADDR`.

**Trusted proxies / request scheme**: `/etc/nginx/http.d/06-trusted-proxy.conf` lists the peers that may assert the external request scheme, with the same ranges as `05-real-ip.conf`. Only those peers can turn `HTTPS`, `HTTP_SCHEME` and `SERVER_PORT` into `on` / `https` / `443` via `X-Forwarded-Proto: https` or the legacy `X-Use-Https: on`; a request from any other peer always reaches PHP as plain HTTP on port 80. Override both files together when your proxy sits outside the private ranges.

**Server-side files are never static content**: PHP source variants (`.php`, `.php7`, `.phps`, `.phtml`, `.pht`, `.phar`, `.inc`, compound suffixes such as `.php.bak`, and any case spelling) are rejected with 404 unless the image executes them, and so are editor backups and dumps (`~`, `.bak`, `.old`, `.orig`, `.save`, `.swp`, `.swo`, `.sql`, `.sqlite`). In `whatwedo/nginx-php` every existing lowercase `.php` file executes; in `whatwedo/symfony` only `/index.php` does.

### PHP

(installed in `whatwedo/php`, `whatwedo/nginx-php`, `whatwedo/symfony`)

PHP 8.4 from [Sury's Debian APT repository](https://packages.sury.org/php/) with the following modules:

apcu, bcmath, calendar, common, curl, dom, gd, iconv, imagick, intl, mbstring, mariadb (mysql), opcache, pcntl, pdo, pdo-mariadb (pdo-mysql), pdo-pgsql, pdo-sqlite, pgsql, phar, posix, readline, simplexml, soap, sqlite3, tokenizer, xml, xmlreader, xmlwriter, zip

PHP from Sury's APT repository ships with additional compiled-in modules such as `sodium`. Run `php -m` inside the container to see the full list.

The `imagick` extension and Ghostscript are installed, so PHP Imagick can render PDF pages without additional packages. The ImageMagick **command line tools** require a separate installation. If your application shells out to `convert`/`magick`, install them in a root build phase:

```dockerfile
USER root
RUN apt-install imagemagick
USER app
```

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
| pm.max_requests | 500 |
| request_terminate_timeout | 120s |
| date.timezone | `${TZ}` (the images set `TZ=Europe/Zurich`) |

PHP reads `date.timezone` from the container's `TZ` variable, so overriding `TZ` moves the PHP timezone with it. Clearing `TZ` leaves PHP without a timezone and it falls back to UTC.

#### PHP Configuration Paths

- Shared custom configs (CLI + FPM): `/etc/php/8.4/conf.d/`
- CLI config: `/etc/php/8.4/cli/php.ini`
- CLI custom configs: `/etc/php/8.4/cli/conf.d/`
- FPM config: `/etc/php/8.4/fpm/php-fpm.conf`
- FPM pool: `/etc/php/8.4/fpm/pool.d/www.conf`
- FPM custom configs: `/etc/php/8.4/fpm/conf.d/`

The shared `conf.d/` is scanned by both CLI and FPM via `PHP_INI_SCAN_DIR`. Use it for configs that should apply to both SAPIs (e.g. xdebug). SAPI-specific configs go into the respective `cli/conf.d/` or `fpm/conf.d/`. Shared PHP settings such as upload limits and timezone live in `99-whatwedo.ini`; override them by adding a file that sorts after it. FPM settings (`pm.*`, `request_terminate_timeout`) and the FPM `php_admin_value[memory_limit]` belong in `/etc/php/8.4/fpm/pool.d/`, not in PHP's `conf.d`. See the [pool override example](https://github.com/whatwedo/docker-base-images/blob/v3.0/MIGRATION-v3.md#6-update-php-configuration-paths).

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

Because the images set `USER app`, upstart and all services run as the **`app`** user — there is no root phase at runtime. Use upstart scripts for startup work the `app` user can do (run database migrations, warm a cache, seed data):

```bash
#!/bin/sh
# /etc/upstart/50-migrate.sh
php /var/www/bin/console doctrine:migrations:migrate --no-interaction
```

> **Do not use an upstart script to `chown` files.** `app` has no `CAP_CHOWN`, so `chown` on a root-owned path fails with *Operation not permitted*, and because upstart runs under `set -e` that aborts startup. Make runtime-writable directories `app`-owned at **build time** (`chown -R app:app …` in a `USER root` block in your Dockerfile). For mounted volumes, configure ownership at deploy time: Kubernetes Pod-level `securityContext.fsGroup: 10001` applies where supported by the volume type and storage driver; other volumes and host paths need ownership prepared separately. See [MIGRATION-v3.md](https://github.com/whatwedo/docker-base-images/blob/v3.0/MIGRATION-v3.md#2-fix-file-permissions).

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
| `whatwedo/nginx`, `whatwedo/nginx-php`, `whatwedo/symfony` | 8080 |

## Migrating from v2.x

See [MIGRATION-v3.md](https://github.com/whatwedo/docker-base-images/blob/v3.0/MIGRATION-v3.md) for a complete migration guide.

## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.

## License

This image is licensed under the MIT License. The full license text is available in [LICENSE](https://github.com/whatwedo/docker-base-images/blob/v3.0/LICENSE).
