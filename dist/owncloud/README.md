# whatwedo base image - ownCloud

## Usage

```
docker run \
    -p 80:80 \
    whatwedo/owncloud
```

## docker-compose

```
owncloud:
  restart: always
  image: whatwedo/owncloud
  links:
    - "db:db"
  ports:
    - "80:80"
db:
  restart: always
  image: whatwedo/mariadb:latest
  ports:
    - "3306:3306"
  environment:
    - MYSQL_ROOT_PASSWORD=mysecretpassword
    - MYSQL_DATABASE=owncloud
  volumes:
    - /var/lib/mysql
```

## Environment Variables

* `CONTAINER_TIMEZONE` - timezone which should be used, default: `Europe/Zurich` ([see Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))

## Volumes

* /var/www/html
* /etc/firstboot

## Exposed Ports

* 80

## Built

Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh)

## Bugs and Issues

### known limitations

* we're encrypting the traffic via a reverse proxy on the docker hosts, so there is no SSL configuration in this container
* there is only the backup directory as a volume available - otherwise we can't restore backups because of a bug
* we're using MariaDB only, so there is no option to configure PostgreSQL at the moment

If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

## License

This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

## Further information

There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
