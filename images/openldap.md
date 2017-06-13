# whatwedo base image - openLDAP

In this image is a basic openLDAP server installation available.


## Usage

```
docker run -p 389:389 -e SLAPD_PASSWORD=mysecretpassword -e SLAPD_DOMAIN=acme.local whatwedo/mariadb
```


## Environment Variables

* `SLAPD_PASSWORD` - Password of the default `admin` user.
* `SLAPD_DOMAIN` - LDAP Domain


## Volumes

* /var/lib/ldap
* /etc/ldap/slapd.d
* /etc/firstboot


## Exposed Ports

* 389


## Built

Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh)


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)


## License

This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).


## Further information

There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
