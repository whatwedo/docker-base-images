[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v2.8/pipeline.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v2.8)

## Introduction & Versions
See README: https://github.com/whatwedo/docker-base-images/

## Images

| Name | Description |
|---|---|
| `whatwedo/base` | Base image with health check and init system |
| `whatwedo/nginx` | nginx web server |
| `whatwedo/nginx-php` | nginx web server and PHP-FPM |
| `whatwedo/php` | PHP interpreter |
| `whatwedo/symfony` | Symfony image based on nginx and PHP-FPM |
| `whatwedo/yarn` | yarn package manager |


## Usage

```
docker run whatwedo/base:v2.8
```

## Known problems
PHP image cannot be built because of a bug in Imagick: 
- https://github.com/Imagick/imagick/pull/641

## Directory/File Layout

The following table show the directory layout of this repository:

| Folder | Description |
|---|---|
| `images` | `Dockerfile`, additional files and README's for the different images. |
| `shared`| Files which are use by several images |
| `build_order`| File to defined the order used while building all images |
| `build.sh`| build.sh is a script for building and/or pushing all or single image/s |


## Installed Software

### doas

[OpenDoas](https://github.com/Duncaen/OpenDoas) doas is a minimal replacement for the venerable sudo.

### goss

[goss](https://github.com/aelsabbahy/goss) is a tool for validating a server’s configuration and health. goss is preconfigured to run several checks which are automatically exposed to Docker health check. If you are using [Kubernetes](https://kubernetes.io/), you can run `goss validate` as liveness/readyness probe.

If you want to add you own checks, you can place it in the `/etc/goss/conf.d` directory.

### PHP

(only installed if you are using `whatwedo/php`, `whatwedo/nginx-php` or `whatwedo/symfony`)

The following PHP modules are installed per default:

- `apcu`
- `bcmath`
- `calendar`
- `ctype`
- `curl`
- `date`
- `dom`
- `filter`
- `gd`
- `hash`
- `iconv`
- `imagick`
- `intl`
- `json`
- `libxml`
- `mbstring`
- `mysqli`
- `mysqlnd`
- `openssl`
- `pcntl`
- `pcre`
- `pdo`
- `pdo_mysql`
- `pdo_sqlite`
- `phar`
- `posix`
- `readline`
- `Reflection`
- `session`
- `soap`
- `spl`
- `standard`
- `xml`
- `xmlreader`
- `opcache`
- `zip`
- `zlib`

#### Custom Settings
The following custom setting were made

|key|value|
|---|--- |
| upload_max_filesize| 128M |
| post_max_size| 128M |
| php_admin_value[upload_max_filesize]| 128M |
| pm.max_children| 10 |
| pm.start_servers| 1 |
| pm.min_spare_servers| 1 |
| pm.max_spare_servers| 5 | 
 
### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. runit is configured to load and monitor all services in the `/etc/service` directory. goss is configured check the runit service health.


### nginx

(only installed if you are using `whatwedo/nginx` or `whatwedo/nginx-php`)

[nginx](https://www.nginx.com/) is configured to use it with PHP sites using PHP-FPM. Place your site in `/var/www` to serve it. 


### yarn

(only installed if you are using `whatwedo/yarn`)

[yarn](https://yarnpkg.com) is a fast and reliable JavaScript package manager. 


## Upstart

The default command (`CMD`) of this image is set to `/sbin/upstart`. `/sbin/upstart` provides a simple init logic. You are able to place one or multiple scripts in the `/etc/upstart` directory. These scripts are going to be automatically executed in alphabetical order at the container startup. After running all scripts, `/sbin/upstart` will trigger the runit execution.


## Environment Variables

This image is not using any environment variables.


## Exposed Ports

This image is not using any exposed ports.


## Volumes

This Image is not using any volumes.
