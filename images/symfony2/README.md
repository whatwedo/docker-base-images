[![Docker Pulls](https://img.shields.io/docker/pulls/whatwedo/symfony2.svg)](https://cloud.docker.com/u/whatwedo/repository/docker/whatwedo/symfony2)
[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v2.0/build.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v2.0)

# whatwedo/symfony2

`whatwedo/symfony2` is an image configured for serving Symfony 2 applications. It has an installed [nginx](https://www.nginx.com/) server, [PHP](http://www.php.net/) interpreter, PHP-FPM, git, [Composer](https://getcomposer.org/), an init system and a container health check. It's based on [Alpine Linux](https://alpinelinux.org/).


## Supported tags respective tag specific documentation link/Dockerfile

| Tag | State | OS | PHP Version |
|---|---|---|---|
| [`v2.0`, `v2.0-[BUILD-DATE]`](https://github.com/whatwedo/docker-base-images/blob/v2.0/images/symfony2) | Stable | Alpine 3.9 | 7.3 |
| [`v1.7`, `v1.7-[BUILD-DATE]`](https://github.com/whatwedo/docker-base-images/blob/v1.7/images/symfony2.md) | Security fixes only | Ubuntu 14.04 | 5.6 |

There will be no `latest` tag available in future. Using a `latest` tag can cause a lot of troubles, especially if you are using Docker in production. Currently there is a latest tag available due to compatibility issues, but it will be removed in summer 2019. Please use the current stable tag (`v2.0`) instead.


## Usage

```
docker run -p 80:80 -v [YOUR-PROJECT-ROOT]:/var/www whatwedo/symfony2:v2-0-dev
```


## Installed Software

### gosu

[gosu](https://github.com/tianon/gosu) is a lightweight tool used for changing the current user. gosu don't have very strange and often annoying TTY and signal-forwarding behavior like `su` or `sudo`.


### goss

[goss](https://github.com/aelsabbahy/goss) is a tool for validating a server’s configuration and health. goss is preconfigured to run several checks which are automatically exposed to Docker health check. If you are using [Kubernetes](https://kubernetes.io/), you can run `goss validate` as liveness/readyness probe.

If you want to add you own checks, you can place it in the `/etc/goss/conf.d` directory.


### nginx

[nginx](https://www.nginx.com/) is configured to use it with Symfony 2 applications using PHP-FPM. Place your application in `/var/www` to serve it. 


### PHP

[PHP](http://www.php.net/) is installed using the [codecasts/php-alpine](https://github.com/codecasts/php-alpine) apk repository. The following PHP modules are installed per default:

* php-apcu
* php-common
* php-curl
* php-ctype
* php-dom
* php-iconv
* php-imagick
* php-intl
* php-json
* php-ldap
* php-mbstring
* php-mysqli
* php-mysqlnd
* php-opcache
* php-openssl
* php-pcntl
* php-pdo
* php-pdo_mysql
* php-pdo_sqlite
* php-phar
* php-posix
* php-session
* php-soap
* php-xml
* php-zip


### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. runit is configured to load and monitor all services in the `/etc/service` directory. goss is configured check the runit service health.


## Upstart

The default command (`CMD`) of this image is set to `/sbin/upstart`. `/sbin/upstart` provides a simple init logic. You are able to place one or multiple scripts in the `/etc/upstart` directory. These scripts are going to be automatically executed in alphabetical order at the container startup. After running all scripts, `/sbin/upstart` will trigger the runit execution.


## Environment Variables

This image is not using any environment variables.


## Exposed Ports

* 80


## Volumes

This Image is not using any volumes.


## Development Workflow

It's sometimes quite hard to use Docker in your development workflow. We decided to face this problem with our own helper toolset called `dde` (available on GitHub at [whatwedo/dde](https://github.com/whatwedo/dde)). `dde` is optimised to use it together with this image. Using `dde` is just a suggestion and not a requirement to use this image in your project.


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.


## License
This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.0/LICENSE.


## Further information
There are a number of images we are using at [whatwedo](https://whatwedo.ch/). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
