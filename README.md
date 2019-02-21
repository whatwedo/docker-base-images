[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v2.0/build.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v2.0)


# whatwedo - Docker Base Images

We at [whatwedo](https://whatwedo.ch/) are slowly going away from traditional application hosting to the approach of using Docker containers. For this reason we built several docker images. They are available on [Dockerhub](https://hub.docker.com/u/whatwedo/). You can use them easily in your own projects.


## Images

| Name | Description |
|---|---|
| [whatwedo/base](images/base) | Base image with health check and init system |
| [whatwedo/nginx](images/nginx) | nginx web server |
| [whatwedo/nginx-php](images/nginx-php) | nginx web server and PHP-FPM |
| [whatwedo/php](images/php) | PHP interpreter |
| [whatwedo/symfony2](images/symfony2) | Symfony 2 image based on nginx and PHP-FPM |
| [whatwedo/symfony3](images/symfony3) | Symfony 3 image based on nginx and PHP-FPM |
| [whatwedo/symfony4](images/symfony4) | Symfony 4 image based on nginx and PHP-FPM |
| [whatwedo/yarn](yarn) | yarn package manager |


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

This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.0/LICENSE.


## Further information

There are a number of images we are using at [whatwedo](https://whatwedo.ch/). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
