# whatwedo base image - CloudFlare Railgun

In this image is CloudFlare Railgun installed

## Usage

```
docker run \
    -e MEMCACHED_SERVERS=memcached:11211 \
    -e ACTIVATION_TOKEN=123abc \
    -e ACTIVATION_RAILGUN_HOST=127.0.0.1 \
    cloudflare-railgun
```

## Environment Variables

* `CONTAINER_TIMEZONE` - timezone which should be used, default: `Europe/Zurich` ([see Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
* `MEMCACHED_SERVERS` - commaseperated list of memcached servers
* `ACTIVATION_TOKEN` = cloudflare activation token
* `ACTIVATION_RAILGUN_HOST` = cloudflare activation railgun host

## Volumes

* /etc/firstboot

## Exposed Ports

* `2408` - Railgun Endpoint
* `24088` - Railgun Statistics

## Built

Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh)

## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

## License

This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

## Further information

There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).