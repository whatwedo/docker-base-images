# whatwedo/yarn

`whatwedo/yarn` is a small image providing [yarn](https://yarnpkg.com), git, an init system and container healthcheck. It's based on [Alpine Linux](https://alpinelinux.org/).

**Note:** You are currently looking at the unstable v2.0-dev branch. You should use the current stable version available at https://github.com/whatwedo/docker-base-images.


## Supported tags respective tag specific documentation links

* [`v2.0-dev`, `v2.0-dev-[BUILD-DATE]`](https://github.com/whatwedo/docker-base-images/blob/v2.0-dev/images/yarn)

There will be no `latest` tag available in future. Using a `latest` can cause a lot of troubles, especially if you are using Docker in production.


## Usage

```
docker run whatwedo/yarn:v2-0-dev
```


## Installed Software

### gosu

[gosu](https://github.com/tianon/gosu) is a lightweight tool used for changing the current user. gosu don't have very strange and often annoying TTY and signal-forwarding behavior like `su` or `sudo`.


### goss

[goss](https://github.com/aelsabbahy/goss) is a tool for validating a server’s configuration and health. goss is preconfigured to run several checks which are automatically exposed to Docker healthcheck. If you are using [Kubernetes](https://kubernetes.io/), you can run `goss validate` as liveness/readyness probe.

If you want to add you own checks, you can place it in the `/etc/goss/conf.d` directory.


### runit

[runit](http://smarden.org/runit/) is a lightweight init system with service supervision. runit is configured to load and monitor all services in the `/etc/service` directory. goss is configured check the runit service health.


### yarn

[yarn](https://yarnpkg.com) is a fast and reliable JavaScript package manager. 


## Upstart

The default command (`CMD`) of this image is set to `/sbin/upstart`. `/sbin/upstart` provides a simple init logic. You able to place one or multiple scripts in the `/etc/upstart` directory. These scripts are going to be automatically executed in alphabetical order at the container startup. After running all scripts, `/sbin/upstart` will trigger the runit execution.


## Environment Variables

This image is not using any environment variables.


## Exposed Ports

This image is not exposing any ports.


## Volumes

This Image is not using any volumes.


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.


## License
This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.0-dev/LICENSE.


## Further information
There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
