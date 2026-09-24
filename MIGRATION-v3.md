# Migration Guide: v2.x to v3

This guide covers migration from v2.10 and v2.11 (Alpine-based) to the published v3.0 branch (Debian-based).

## Overview

v3.0 moves from Alpine Linux (musl libc) to Debian 13 Trixie Slim (glibc). Rebuild native dependencies for Debian even when the language version stays the same. For v2.11 users, the migration also lowers PHP, Node.js and npm versions.

## Breaking Changes Summary

| Component | v2.10 / v2.11 (Alpine) | v3.0 (Debian) | Action Required |
|-----------|---------------|-------------|-----------------|
| Base OS | Alpine 3.22/3.23 | Debian 13 (Trixie) | Test application compatibility |
| libc | musl | glibc | Rebuild native PHP extensions and Node.js addons |
| PHP | 8.4 / 8.5 | 8.4 | Check PHP syntax and Composer requirements when coming from v2.11 |
| Node.js | 22.x / 24.x | 22.x | Check Node.js engines and rebuild dependencies |
| npm | Alpine package; v2.11 introduced 11.x | Pinned 10.x | Check package-manager and lockfile compatibility |
| Yarn | installed | not installed | Install the version your project requires, or deliberately migrate package managers |
| Shell | `/bin/sh` uses BusyBox ash | `/bin/sh` uses dash; Bash is available | Replace `/bin/ash` shebangs and test shell scripts |
| Service user | `nginx` (variable UID) | `app` (UID 10000 / GID 10001) | **Update file permissions** |
| Package manager | `apk` | `apt-get` | Update custom Dockerfiles |
| Privilege escalation | `doas` | None (`--user root`) | See "Update Privilege Escalation" |
| Service directory | `/etc/service/` | `/etc/runit/runsvdir/default/` | Move custom services |
| PHP config path | `/etc/php84/` / `/etc/php85/` | `/etc/php/8.4/` | Update custom configs |
| FPM socket | `/var/run/php-fpm.sock` | `/tmp/php-fpm.sock` | Update custom `fastcgi_pass` directives |
| FPM request lifetime | No image-configured termination limit | 120 seconds | Override the FPM pool setting if a different limit is required |
| Default USER | `root` | `app` | Commands run as app by default |
| nginx port | `80` | `8080` | **Update port mappings, probes, ingress** |
| ImageMagick CLI | installed | not installed | Add `apt-install imagemagick` if you shell out to `convert` |
| PHP development tools | PHP-dev, PEAR and compiler tools installed | not preinstalled | Install the tools and libraries needed to build your extensions |
| BusyBox utilities | `wget`, `crond`, `crontab` available | not included | Use curl or install and configure the required tools |
| Process tools | `ps` available | `procps` not installed | `apt-install procps` where scripts or debugging rely on `ps` |
| Docker HEALTHCHECK | inherited by every image | only nginx, nginx-php and symfony | Define application-specific checks for base, PHP CLI and Node.js derivatives |
| PHP-like static files | could be served as source | 404 outside intended PHP entrypoints | Review intentionally downloadable files and custom locations |
| Forwarded client IP | `X-Real-IP` accepted | `X-Forwarded-For` from trusted peers | Configure the proxy and `05-real-ip.conf` |
| Forwarded scheme | any client | trusted proxy peers only | Configure both `05-real-ip.conf` and `06-trusted-proxy.conf` |
| Response headers | no image-provided security headers | framing and browser-feature restrictions | Review applications using frames, camera, microphone or geolocation |

## Step-by-Step Migration

### 1. Update Image Tags

**Before:**

```dockerfile
FROM whatwedo/nginx-php:v2.11
```

**After:**

```dockerfile
FROM whatwedo/nginx-php:v3.0
```

Update **every relevant `FROM` stage**, including dependency builders. Do not copy Alpine-built PHP extensions, native binaries or `node_modules` into a Debian runtime. Install or rebuild native dependencies in a Debian stage with the target PHP/Node.js version and architecture.

Coming from **v2.11**, check that the application and its locked dependencies support PHP 8.4, Node.js 22.x and npm 10.x. PHP 8.5-only syntax or a Node.js 24 minimum will need application changes before this tag switch. Coming from **v2.10**, PHP 8.4 and Node.js 22.x remain the same version lines, but the libc change still requires rebuilding native modules.

Yarn is no longer supplied. If your project uses it, install the specific Yarn version expected by that project and keep its lockfile workflow. Switching to npm is a separate migration, not a drop-in command replacement. The Node.js image pins npm to an exact 10.x release and verifies both its version and a minimum version of its bundled tar during installation; a downstream global npm upgrade must account for those checks.

### 2. Fix File Permissions

The service user changed from `nginx` to `app` (UID/GID `10000:10001`). All processes run as `app` — and so does `/usr/sbin/upstart` and `runsvdir`, because the images set `USER app`. **There is no root phase at runtime**, and `app` holds no `CAP_CHOWN`, so the container cannot `chown` root-owned paths from inside. Fix ownership where you actually have privilege:

**1. Directories baked into the image** (anything written at runtime that ships in the image — `var/cache`, `var/log`, a storage dir): make them `app`-owned at **build time**. The `--chown=app:app` on your `COPY … /var/www` usually covers it; otherwise add it explicitly in your Dockerfile:

```dockerfile
USER root
RUN mkdir -p /var/www/var/storage && chown -R app:app /var/www/var/storage
USER app
```

**2. Volumes mounted at runtime** that arrive owned by `root`: the container can't fix these itself. In Kubernetes, set the Pod-level `securityContext.fsGroup: 10001` where the volume type and storage driver support applying that group. It does not fix every volume or host path; provision ownership separately where unsupported. In Docker Compose, prepare writable host paths or volume contents for uid `10000` / gid `10001` before starting the application. Docker creates a missing bind-mount source as a root-owned directory, so create and own the paths first, for example from a deploy script that only has the Docker socket:

```bash
mkdir -p data/var/log data/var/private-files
docker run --rm --user root -v "$PWD/data:/data" whatwedo/base:v3.0 chown -R 10000:10001 /data
```

**3. `COPY --chmod` and parent directories**: BuildKit applies `--chmod` to directories it creates for the destination as well. `COPY --chmod=644 config.yaml /etc/app/config.yaml` leaves `/etc/app` with mode `644`, which `app` cannot enter. Create the directory in a root build step before such a `COPY`.

> Do **not** add a `chown` upstart script (a `10-permissions.sh` that runs `chown -R app:app …`). Because upstart runs as `app`, such a script can't change a root-owned path — it fails with *Operation not permitted*, and since upstart runs under `set -e`, that failure aborts container startup. Fix ownership at build time or at deploy time instead.

### 3. Update Package Installation

v3 includes an `apt-install` helper that wraps `apt-get update`, `apt-get install --no-install-recommends`, and cache cleanup into a single command. It must run as root:

```dockerfile
# Before (v2.x - Alpine)
RUN apk add --no-cache imagemagick ffmpeg

# After (v3)
USER root
RUN apt-install imagemagick ffmpeg
USER app
```

The `imagick` PHP extension and Ghostscript are included, so rendering PDF pages through PHP Imagick continues to work without additional packages. The ImageMagick command line tools require a separate installation. If your application shells out to the ImageMagick CLI (for example, the imagemagick driver of LiipImagineBundle), install the package explicitly as shown above.

PHP development headers, PEAR/PECL tools and compiler dependencies are no longer preinstalled. Derived images compiling extensions must install the matching PHP 8.4 development packages, a compiler toolchain and any required development libraries in a root build step. Remove Alpine-specific `musl-dev` and package names from those steps.

`make` is included in the base image and inherited by all derived images. CI jobs using the built application image run as `app`; ensure their Makefile targets work without root privileges. Jobs using a separate Alpine CI image still use `apk` — change package commands according to the image that actually executes them.

`/bin/sh` now uses Debian's dash, and `/bin/ash` is absent. Audit startup and runit scripts for BusyBox-specific commands and shell syntax such as `[[ ... ]]`. Use portable shell syntax or select `#!/bin/bash` explicitly where Bash is required. Debian 13's dash supports `set -o pipefail`; it is not necessary to remove that option solely because the shell changed.

BusyBox's `wget`, `crond` and `crontab` are no longer available by default. curl is installed for downloads. If you need scheduled jobs inside the container, install and configure an appropriate scheduler explicitly; Debian cron is not a drop-in replacement for a BusyBox `crond` service, especially when the service runs as `app`.

Downloaded native extensions and probes also need the vendor's **Linux/glibc build**, not its Alpine/musl build. For example, the [Blackfire PHP probe](https://docs.blackfire.io/php/integrations/php-docker) URL changes from `.../probe/php/alpine/...` to `.../probe/php/linux/...`. In a PHP CLI/FPM development stage:

```dockerfile
USER root
RUN BF_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;') && \
    curl -fsSL -A Docker -o /tmp/blackfire-probe.tar.gz \
        "https://blackfire.io/api/v1/releases/probe/php/linux/$(uname -m)/$BF_VERSION" && \
    mkdir -p /tmp/blackfire && \
    tar xzf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire && \
    mv /tmp/blackfire/blackfire-*.so "$(php -r 'echo ini_get("extension_dir");')/blackfire.so" && \
    rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
USER app
COPY ./docker/dev/rootfs /
```

For v3.0, `BF_VERSION` is `84`; `uname -m` selects the build architecture. Copy the development INI that loads `blackfire.so` only **after** installing the probe, otherwise the `php -r` commands above try to load a file that does not yet exist. FrankenPHP needs the vendor's ZTS variant (`84-zts`), not this CLI/FPM probe.

The shipped MariaDB client configuration moved from `/etc/my.cnf.d/disable_ssl.cnf` to `/etc/mysql/mariadb.conf.d/disable_ssl.cnf`. Update any custom copies or mounts at the old path; this configuration file does not itself install a MariaDB client.

> If you run `nginx -t` inside a `USER root` block of your own Dockerfile, delete `/tmp/nginx.pid` afterwards. It stays behind owned by `root`, and the container then fails to start with *open() "/tmp/nginx.pid" failed (13: Permission denied)*.

### 4. Update Privilege Escalation

In v2.x, containers ran as root by default. You could drop to the nginx user with `doas`:

```bash
# v2.x — enter container as root (default)
docker exec -it container-name sh

# v2.x — run as nginx user
docker exec -it container-name doas -u nginx sh
```

In v3, containers run as the `app` user by default. There is no `sudo` or `doas` inside the container. Use Docker's `--user` flag to exec as root when needed:

```bash
# v3 — enter container as app (default)
docker exec -it container-name bash

# v3 — enter container as root
docker exec -it --user root container-name bash
```

### 5. Move Custom Services

The service directory changed from `/etc/service/` to `/etc/runit/runsvdir/default/`. The `/etc/service` symlink no longer exists.

If you added custom runit services, place them in the new directory:

- v2.x: `/etc/service/<name>/run`
- v3: `/etc/runit/runsvdir/default/<name>/run`

Keep each `run` script executable in Git and copy the service directories as `app`. `runsv` then creates its `supervise/` state directory itself at startup:

```dockerfile
COPY ./docker/prod/rootfs /
COPY --chown=app:app ./docker/prod/rootfs/etc/runit /etc/runit
```

The second copy sets ownership for the runit overlay; it needs no `USER root` block. A regular `COPY` alone creates root-owned service directories, preventing `runsv` from creating its lock, status and control files.

If the `run` script and service directory should remain root-owned, create only the writable state directory at build time instead:

```dockerfile
COPY --chmod=755 docker/worker/run /etc/runit/runsvdir/default/worker/run
USER root
RUN mkdir -p /etc/runit/runsvdir/default/worker/supervise \
    && chown -R app:app /etc/runit/runsvdir/default/worker/supervise
USER app
```

Use `exec` to start the worker in `run`, so runit supervises the worker process directly. For mounted services, make the service directory writable by `app` or provide an `app`-owned `supervise/` directory on that mount. Upstart runs as `app` and cannot fix root-owned directories at startup.

### 6. Update PHP Configuration Paths

PHP configuration paths changed from `/etc/php84/` (v2.10) or `/etc/php85/` (v2.11) to Debian's versioned structure. Place custom configs in:

- **Shared (CLI + FPM):** `/etc/php/8.4/conf.d/` — for configs that apply to both SAPIs (e.g. xdebug)
- **CLI config:** `/etc/php/8.4/cli/conf.d/`
- **FPM config:** `/etc/php/8.4/fpm/conf.d/`
- **FPM pool config:** `/etc/php/8.4/fpm/pool.d/`

The shared `/etc/php/8.4/conf.d/` is wired up via `PHP_INI_SCAN_DIR`, which keeps each SAPI's own `conf.d` in the scan path. The image's own settings live in `/etc/php/8.4/conf.d/99-whatwedo.ini` — to change one, drop a file that sorts after it instead of editing `php.ini`.

Debian extension packages such as `php8.4-xdebug` enable their extensions themselves through `mods-available/` and links in `cli/conf.d/` and `fpm/conf.d/`. Keep the project's Xdebug INI to settings such as `xdebug.mode` and `xdebug.client_host`; remove its old `zend_extension=xdebug.so` line, which would load Xdebug twice. The same applies to duplicate `extension=` lines for package-enabled extensions. A manually downloaded extension such as Blackfire still needs its own loading directive.

FPM process settings such as `pm.max_requests` and `request_terminate_timeout` belong in the **pool configuration**, not PHP's `conf.d`. The defaults now recycle workers after 500 requests and terminate a request after 120 seconds. If the application needs a different request limit, add a file such as `/etc/php/8.4/fpm/pool.d/zz-application.conf`:

```ini
[www]
request_terminate_timeout = 300s
```

Choose the limit for your application and review proxy timeouts too.

The image also sets `php_admin_value[memory_limit] = 128M` in `www.conf`. Unlike scalar pool settings such as `request_terminate_timeout`, duplicate `php_admin_value` entries are applied in reverse declaration order by the shipped PHP-FPM ([PHP 8.4 configuration parser](https://github.com/php/php-src/blob/PHP-8.4/sapi/fpm/fpm/fpm_conf.c), [application of pool values](https://github.com/php/php-src/blob/PHP-8.4/sapi/fpm/fpm/fpm_php.c)). To override this administrative memory limit, load it **before** `www.conf`, for example in `/etc/php/8.4/fpm/pool.d/00-application.conf`:

```ini
[www]
php_admin_value[memory_limit] = 1G
```

Use a separate shared `conf.d/zz-application.ini` with `memory_limit = 1G` if CLI needs the same value. Verify the effective setting through an FPM request: `php -i` checks CLI, and `php-fpm8.4 -tt` can list both duplicate values without proving which is effective. A `zz-` pool file remains appropriate for scalar settings such as the timeout above.

For a direct FastCGI check, replace `your-app:v3.0` with the built application image containing your override. This disposable container installs the client and starts only FPM, without running application startup hooks or workers:

```bash
docker run --rm -i --user root --entrypoint sh your-app:v3.0 -s <<'SH'
set -eu
apt-install libfcgi-bin
printf '%s\n' '<?php echo ini_get("memory_limit"), PHP_EOL;' > /tmp/fpm-memory.php
php-fpm8.4 -D
SCRIPT_FILENAME=/tmp/fpm-memory.php REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect /tmp/php-fpm.sock
SH
```

With the pool override above, the response body should be `1G`. The client and probe file disappear when this container exits.

The FastCGI socket moved to `/tmp/php-fpm.sock`. If you maintain your own FastCGI location, update its upstream:

```nginx
fastcgi_pass unix:/tmp/php-fpm.sock;
```

### 7. Update the nginx Port

nginx now listens on **8080** instead of 80. The images run as the unprivileged `app` user; binding port 80 required granting `CAP_NET_BIND_SERVICE` to the nginx binary, and that makes the container fail to start (`exec: Operation not permitted`) as soon as the runtime drops capabilities — which the Kubernetes *restricted* Pod Security Standard requires.

Adjust wherever the container port appears:

```yaml
# docker-compose
ports:
  - "80:8080"

# Kubernetes
containerPort: 8080
```

Also update health and readiness probes, `Service.targetPort`, and Traefik labels (`traefik.http.services.<name>.loadbalancer.server.port=8080`). PHP receives `SERVER_PORT` 80, or 443 when a **trusted proxy peer** signals HTTPS. Configure that trust as described below.

If you ship your own server block, change its `listen` directive too:

```nginx
server {
    listen 8080;
    root /var/www;
    include /etc/nginx/server.d/default.d/*.conf;
}
```

For the Symfony image, retain `/var/www/public` as the document root.

**Expected startup messages:** when starting as `app`, nginx warns that its `user` directive is ignored, and FPM reports the same for the pool's `user` and `group` directives. The processes already run as `app`; these directives remain so whatwedo/dde can rewrite the worker identities when it starts the container as root. They do not indicate a startup failure.

### 8. Update Proxy Trust and Custom nginx Configuration

Configure your proxy to supply `X-Forwarded-For` for the client address and `X-Forwarded-Proto: https` for HTTPS. The legacy `X-Use-Https: on` header is also supported for the scheme. `X-Real-IP` is no longer used to populate PHP's `REMOTE_ADDR`.

The default trust lists cover private networks. When adding a proxy outside those ranges, or narrowing trust to your actual proxies, update **both** `/etc/nginx/http.d/05-real-ip.conf` and `/etc/nginx/http.d/06-trusted-proxy.conf`. The first controls client-IP replacement; the second controls who may assert HTTPS and matches the actual connection peer through `$realip_remote_addr`.

For example, to trust only one proxy, replace both files as follows. `192.0.2.10` is a documentation address: replace it with the proxy peer address that the container actually sees.

```nginx
# /etc/nginx/http.d/05-real-ip.conf
set_real_ip_from 192.0.2.10;
real_ip_header X-Forwarded-For;
real_ip_recursive on;
```

```nginx
# /etc/nginx/http.d/06-trusted-proxy.conf
geo $realip_remote_addr $trusted_proxy {
    default 0;
    192.0.2.10 1;
}
```

List every intended proxy in both files when there is more than one. A peer that is absent from the second list cannot assert HTTPS, even if it appears in the first.

If you replace the **whole `nginx.conf`**, retain the HTTP configuration includes. `/etc/nginx/http.d/07-forwarded-scheme.conf` defines `$external_port`, `$external_https` and `$external_scheme`, which the shared `php-fpm-file.conf` now requires. A configuration that includes only `server.d` fails validation with an unknown-variable error. This complete example preserves the image's runtime paths and HTTP includes:

```nginx
worker_processes auto;
daemon off;
error_log /dev/stderr;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/http.d/*.conf;
    include /etc/nginx/server.d/*.conf;
}
```

All nginx images reject PHP-like source paths, backups and dumps outside their intended PHP entrypoints. Plain nginx rejects PHP source; nginx-php continues to execute existing lowercase `.php` files, and Symfony continues to execute `/index.php` with optional path info. Review custom downloads using suffixes such as `.inc`, `.bak`, `.sql` or `.sqlite`; move private files outside the document root and explicitly design a location or application endpoint for any files intended to remain downloadable.

The new defaults also add `X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` and `Permissions-Policy: camera=(), microphone=(), geolocation=()`. Review cross-origin embeds, content types and applications using those browser features. When defining your own `add_header` in a server or location, explicitly retain the headers you need because nginx replaces inherited `add_header` settings at that level.

### 9. Restore Application Health Checks Where Needed

The base, PHP CLI and Node.js images no longer define a Docker HEALTHCHECK. nginx, nginx-php and symfony retain the automatic goss check. For a derived image with its own command, define a check that tests the running application. If that check uses `goss validate`, add suitable application checks under `/etc/goss/conf.d/`; adding those files alone does not enable Docker health reporting. Update Kubernetes probes separately where they depend on the old command or port.

### 10. Apply Runtime Security Controls

The image's `USER app` instruction selects the fixed UID/GID `10000:10001`, and the services no longer need Linux capabilities. Dropping capabilities and disabling privilege escalation still belong to Docker or Kubernetes; they cannot be embedded in an image.

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10000
  runAsGroup: 10001
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

nginx drains first during shutdown, followed by PHP-FPM and other services. `SHUTDOWN_TIMEOUT` (default `8` seconds) is the shared shutdown budget. If requests need more time to finish, raise it together with Docker's stop timeout or Kubernetes' `terminationGracePeriodSeconds`; the orchestrator can otherwise kill the container before that budget expires.

### 11. Update Repository Build Automation

If you build these base images from source, update callers of `build.sh`: `build` now builds for the local architecture without publishing, `test` tests an already-built image, and `check` builds and tests. Replace old calls that expected `test` to build the image with `check`.

GitHub Actions now builds and tests on native amd64 and arm64 runners. It pushes tested architecture images to GHCR, merges them after both jobs succeed, then copies the merged image to the whatwedo registry and Docker Hub. Image order and test requirements live in `images.conf`. See [build.md](build.md) for commands and registry prerequisites.
