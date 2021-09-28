[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v2.4-dev/pipeline.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v2.4-dev)

# whatwedo - Docker Base Images

We at [whatwedo](https://whatwedo.ch/) are building and deploying all applications using Docker containers. For this reason we built some basic docker images. They are available on [Dockerhub](https://hub.docker.com/u/whatwedo/). You can use them easily in your own projects.


## Images

| Name | Description |
|---|---|
| [whatwedo/base](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/base) | Base image with health check and init system |
| [whatwedo/nginx](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/nginx) | nginx web server |
| [whatwedo/nginx-php](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/nginx-php) | nginx web server and PHP-FPM |
| [whatwedo/php](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/php) | PHP interpreter |
| [whatwedo/symfony5](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/symfony5) | Symfony image based on nginx and PHP-FPM |
| [whatwedo/yarn](https://github.com/whatwedo/docker-base-images/tree/v2.4-dev/images/yarn) | yarn package manager |


## Versions

| Tag | State | OS | PHP Version |
|---|---|---|---|
| `v2.5-dev`, `v2.5-[BUILD-DATE]` | Development | Alpine 3.14 | PHP 8.1 |
| `v2.4-dev`, `v2.4-[BUILD-DATE]` | Development | Alpine 3.14 | PHP 7.4 |


## Directory/File Layout

The following table show the directory layout of this repository:

| Folder | Description |
|---|---|
| `images` | `Dockerfile`, additional files and README's for the different images. |
| `shared`| Files which are use by several images |
| `build_order`| File to defined the order used while building all images |
| `build.sh`| build.sh is a script for building and/or pushing all or single image/s |


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.


## License

This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.4-dev/LICENSE.


## Further information

There are a number of images we are using at [whatwedo](https://whatwedo.ch/). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
