# Migration Guide: v2.x to v3

This guide helps developers migrate applications from whatwedo Docker Base Images v2.x (Alpine-based) to v3 (Debian-based).

## Overview

v3.0 represents a fundamental platform change from Alpine Linux (musl libc) to Debian 13 Trixie Slim (glibc). This migration resolves compatibility issues with third party libraries and provides better binary compatibility.

## Breaking Changes Summary

| Component | v2.x (Alpine) | v3 (Debian) | Action Required |
|-----------|---------------|-------------|-----------------|
| Base OS | Alpine 3.22/3.23 | Debian 13 (Trixie) | Test application compatibility |
| libc | musl | glibc | Recompile native extensions |
| Service user | `nginx` (variable UID) | `app` (UID 10000 / GID 10001) | **Update file permissions** |
| Package manager | `apk` | `apt-get` | Update custom Dockerfiles |
| Privilege escalation | `doas` | None (`--user root`) | See "Update Privilege Escalation" |
| Service directory | `/etc/service/` | `/etc/runit/runsvdir/default/` | Move custom services |
| PHP config path | `/etc/php85/` | `/etc/php/8.4/` | Update custom configs |
| Default USER | `root` | `app` | Commands run as app by default |

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

### 2. Fix File Permissions

The service user changed from `nginx` to `app` (UID/GID `10000:10001`). All services (nginx, PHP-FPM) now run as `app`.

Add an upstart script to your project to fix ownership of your application data at container startup. Create the file with the executable flag set:

```dockerfile
# In your Dockerfile
COPY 10-permissions.sh /etc/upstart/10-permissions.sh
RUN chmod +x /etc/upstart/10-permissions.sh
```

**`10-permissions.sh`:**
```bash
#!/bin/sh
chown -R app:app /var/www/var/storage
```

Adjust the path to match your application's writable directories.

### 3. Update Package Installation

v3 includes a `apt-install` helper that wraps `apt-get update`, `apt-get install`, and cache cleanup into a single command:

```dockerfile
# Before (v2.x - Alpine)
RUN apk add --no-cache imagemagick ffmpeg

# After (v3)
RUN apt-install imagemagick ffmpeg
```

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

### 6. Update PHP Configuration Paths

PHP configuration paths changed from Alpine's flat layout to Debian's versioned structure. Place custom configs in:

- **Shared (CLI + FPM):** `/etc/php/8.4/conf.d/` — for configs that apply to both SAPIs (e.g. xdebug)
- **CLI config:** `/etc/php/8.4/cli/conf.d/`
- **FPM config:** `/etc/php/8.4/fpm/conf.d/`
- **FPM pool config:** `/etc/php/8.4/fpm/pool.d/`

The shared `/etc/php/8.4/conf.d/` is wired up via `PHP_INI_SCAN_DIR` (set in the Dockerfile for CLI, in the FPM run script for FPM).
