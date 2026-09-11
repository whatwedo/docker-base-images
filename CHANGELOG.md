# Changelog

## [v3.0]

See the [migration guide](MIGRATION-v3.md) for upgrade steps and configuration examples.

### Breaking Changes

- **Debian 13 replaces Alpine.** Use APT instead of `apk`, rebuild native extensions for glibc, and update scripts that require BusyBox or `/bin/ash`.
- **PHP 8.4, Node.js 22 and npm 10.** These replace PHP 8.5, Node.js 24 and npm 11 from v2.11; check application compatibility. v2.10 already used PHP 8.4 and Node.js 22.
- **Containers run as `app` (10000:10001).** Update file and volume ownership. Startup hooks run without root privileges; install packages during the image build. `doas` is removed.
- **nginx listens on port 8080 instead of 80.** Update proxy targets, port mappings and probes.
- **PHP configuration moves to `/etc/php/8.4/`.** PHP-FPM uses `/tmp/php-fpm.sock` and terminates requests after 120 seconds; adjust custom configurations and long-running requests.
- **runit services move to `/etc/runit/runsvdir/default/`.** Custom services need executable scripts and writable `supervise` directories.
- **Yarn, PHP development/PEAR tools and ImageMagick CLI tools are no longer bundled.** Install them explicitly when needed; PHP Imagick remains available.
- **`base`, `php` and `nodejs` no longer supply a Docker HEALTHCHECK.** Define an application-specific check where required.
- **nginx requires trusted proxies for forwarded client IPs and HTTPS.** `X-Real-IP` is no longer used. PHP source variants, editor backups and database dumps are blocked.
- **Default browser headers restrict cross-origin framing, camera, microphone and geolocation.** Review overrides if your application uses these features.

### Added

- **FrankenPHP image** with PHP 8.4 ZTS, Composer, and classic or worker mode, following the shared Debian/rootless conventions.
- FrankenPHP configuration as numbered drop-in files under `/etc/frankenphp/{frankenphp.d,site.d,route.d}/`, extendable like nginx's `http.d/` and `server.d/default.d/`.
- `FRANKENPHP_MEMORY_LIMIT` and `PHP_MEMORY_LIMIT` set separate PHP memory limits for HTTP requests and the CLI in the FrankenPHP image.

### Changed

- PHP's timezone follows `TZ` (default `Europe/Zurich`).
- nginx and PHP-FPM finish active requests during shutdown, within `SHUTDOWN_TIMEOUT` (default 8 seconds).
- PHP Imagick can render PDFs through the included Ghostscript.
- Sunday rebuilds refresh APT packages; images are also available from `ghcr.io/whatwedo`.

## [v2.11]

Alpine 3.23, PHP 8.5 and Node.js 24.

## [v2.10]

Alpine 3.22, PHP 8.4 and Node.js 22 LTS.

See the [version overview](https://github.com/whatwedo/docker-base-images/blob/main/README.md) for support status.
