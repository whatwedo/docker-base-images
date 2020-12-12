[![Docker Pulls](https://img.shields.io/docker/pulls/whatwedo/yarn.svg)](https://cloud.docker.com/u/whatwedo/repository/docker/whatwedo/yarn)
[![GitHub issues](https://img.shields.io/github/issues/whatwedo/docker-base-images.svg)](https://github.com/whatwedo/docker-base-images/issues)
[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/v2.2/build.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/v2.2)

# whatwedo/yarn

`whatwedo/yarn` is a small image providing [yarn](https://yarnpkg.com), git, an init system and container health check. It's based on [Alpine Linux](https://alpinelinux.org/).


## Supported tags respective tag specific documentation link/Dockerfile

| Tag | State | OS |
|---|---|---|
| [`v2.3`, `v2.3-[BUILD-DATE]`](https://github.com/whatwedo/docker-base-images/blob/v2.3/images/yarn) | Stable | Alpine 3.12 |
| [`v2.2`, `v2.2-[BUILD-DATE]`](https://github.com/whatwedo/docker-base-images/blob/v2.2/images/yarn) | Security fixes only | Alpine 3.11 |

There is no `latest` latest tag available. Using a `latest` tag can cause a lot of troubles, especially if you are using Docker in production. Please use the current stable tag (`v2.3`) instead.


## Usage

```
docker run whatwedo/yarn:v2.2
```


## Installed Software

### gosu

[gosu](https://github.com/tianon/gosu) is a lightweight tool used for changing the current user. gosu don't have very strange and often annoying TTY and signal-forwarding behavior like `su` or `sudo`.


### goss

[goss](https://github.com/aelsabbahy/goss) is a tool for validating a server’s configuration and health. goss is preconfigured to run several checks which are automatically exposed to Docker health check. If you are using [Kubernetes](https://kubernetes.io/), you can run `goss validate` as liveness/readyness probe.

If you want to add you own checks, you can place it in the `/etc/goss/conf.d` directory.


### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. runit is configured to load and monitor all services in the `/etc/service` directory. goss is configured check the runit service health.


### yarn

[yarn](https://yarnpkg.com) is a fast and reliable JavaScript package manager. 


## Upstart

The default command (`CMD`) of this image is set to `/sbin/upstart`. `/sbin/upstart` provides a simple init logic. You are able to place one or multiple scripts in the `/etc/upstart` directory. These scripts are going to be automatically executed in alphabetical order at the container startup. After running all scripts, `/sbin/upstart` will trigger the runit execution.


## Environment Variables

This image is not using any environment variables.


## Exposed Ports

This image is not exposing any ports.


## Volumes

This Image is not using any volumes.


## Development Workflow

It's sometimes quite hard to use Docker in your development workflow. We decided to face this problem with our own helper toolset called `dde` (available on GitHub at [whatwedo/dde](https://github.com/whatwedo/dde)). `dde` is optimised to use it together with this image. Using `dde` is just a suggestion and not a requirement to use this image in your project.


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.


## License
This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.2/LICENSE.


## Further information
There are a number of images we are using at [whatwedo](https://whatwedo.ch/). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
