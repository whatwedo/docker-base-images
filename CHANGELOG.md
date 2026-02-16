# Changelog

All notable changes to whatwedo Docker Base Images will be documented in this file.

## [v3.0] - 2026-02-12

### Breaking Changes

#### Base Operating System
- **Changed from Alpine Linux 3.23 to Debian 13 (Trixie) Slim**
  - Migrated from musl libc to glibc for better compatibility with third party libraries
  - Package manager changed from `apk` to `apt-get`
  - System paths follow Debian conventions (`/usr/sbin`, `/etc/runit/runsvdir/default`)

#### User and Permissions
- **Service user changed from `nginx` to `app`**
  - Fixed UID/GID: `10000:10001` (previously variable)
  - Home directory: `/home/app`
  - All processes (nginx, PHP-FPM) now run as `app` user
  - **Migration required**: Update volume permissions and file ownership

#### Privilege Escalation
- **Removed `doas`** — no privilege escalation tool is installed
  - Use `docker exec -it --user root <container> bash` to get a root shell
  - No `sudo` or `doas` available inside the container

#### Service Management
- **Service directory structure changed**
  - Services must be placed in `/etc/runit/runsvdir/default/` instead of `/etc/service/`
  - Reason: Debian's runit creates `/etc/service` as a symlink

### Added

#### Security Improvements
- **All images now run as non-root by default** (`USER app`)
  - php, nodejs: Run as app user directly
  - nginx, nginx-php, symfony: Use Linux capabilities (`CAP_NET_BIND_SERVICE`) to allow app user to bind to port 80
  - Improves container security by minimizing attack surface

#### MOTD System
- Dynamic login banner with modular scripts in `/etc/update-motd.d/`

#### Configuration
- **Configurable timezone** via `TZ` environment variable (defaults to `Europe/Zurich`)
- **Shared PHP conf.d** at `/etc/php/8.4/conf.d/` for configs that apply to both CLI and FPM (wired up via `PHP_INI_SCAN_DIR`)

#### Security
- Added nginx security headers:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: SAMEORIGIN`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- Trusted proxy configuration (`set_real_ip_from` for private networks)
- PHP execution guard (`try_files $fastcgi_script_name =404`)
- Integrity verification for third-party software:
  - apt repositories (Sury PHP, NodeSource) added with their GPG key pinned per-source via `signed-by`
  - goss installed from a pinned release and verified against a SHA-256 checksum
  - Composer installer verified against the official SHA-384 signature before execution

### Changed

#### PHP Installation
- Source: Alpine edge packages → Sury PHP PPA (https://packages.sury.org/php/)
- Version: 8.4 (the LTS line; v2.11 had moved to 8.5)
- Install script moved: `/tmp/install-php.sh` → `/usr/local/src/install-php.sh`
- PHP-FPM configuration paths updated to Debian structure: `/etc/php/8.4/fpm/`

#### Node.js Installation
- Source: Alpine packages → NodeSource repository (https://deb.nodesource.com/)
- Version: 22.x LTS (v2.11 had moved to 24.x)
- GPG-signed repository with proper key verification

#### nginx Configuration
- User directive: `user nginx;` → `user app;`
- Default document root ownership: `nginx:nginx` → `app:app`
- Default container user: `root` → `app` (using capabilities for port 80 binding)
- nginx binary granted `CAP_NET_BIND_SERVICE` capability to bind privileged ports as non-root user

### Removed

#### Security Hardening
- Removed `chmod 777 /tmp` from php and nginx-php images (was insecure)
- No privilege escalation tools installed (no sudo, no doas)

#### Alpine-Specific Tools
- `gnu-libiconv` and `LD_PRELOAD` workaround (no longer needed with glibc)
- `doas` privilege escalation tool

### Fixed

- Resolved musl libc compatibility issues with third party libraries
- Fixed `/tmp` permission conflicts during Docker builds
- Corrected service symlink handling for Debian's runit structure

### Build System

- All images continue to support multi-architecture builds: `linux/amd64`, `linux/arm64/v8`
- Single `docker buildx build` with multiple `--tag` flags pushes to both registries at once
- `BUILD_DATE` build arg passed automatically for image provenance
- Goss health checks retained and updated for Debian

---

## [v2.11] - Previous Release

- Base OS: Alpine Linux 3.23
- PHP: 8.5 (Alpine edge)
- Node.js: 24.x
- Status: Deprecated

## [v2.10] - Previous Release

- Base OS: Alpine Linux 3.22
- PHP: 8.4
- Node.js: 22.x LTS
- Status: Deprecated
