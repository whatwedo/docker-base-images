# whatwedo - Docker Base Images

[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/master/build.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/master)

We at [whatwedo](https://whatwedo.ch/) are slowly going away from traditional application hosting to the approach of using Docker containers. For this reason we built several docker images. They are available on [Dockerhub](https://registry.hub.docker.com/repos/whatwedo/). You can use them easily in your own projects.

## Images
| Name | Description |
|---|---|
| [whatwedo/base](https://github.com/whatwedo/docker-base-images/tree/master/images/base.md) | several base packages for daily working with docker installed |
| [whatwedo/apache](https://github.com/whatwedo/docker-base-images/tree/master/images/apache.md) | Apache 2 webserver |
| [whatwedo/apache-php56](https://github.com/whatwedo/docker-base-images/tree/master/images/apache-php56.md) | Apache 2 webserver including PHP 5.6 |
| [whatwedo/apache-php70](https://github.com/whatwedo/docker-base-images/tree/master/images/apache-php70.md) | Apache 2 webserver including PHP 7.0 |
| [whatwedo/apache-php71](https://github.com/whatwedo/docker-base-images/tree/master/images/apache-php71.md) | Apache 2 webserver including PHP 7.1 |
| [whatwedo/apache-php72](https://github.com/whatwedo/docker-base-images/tree/master/images/apache-php72.md) | Apache 2 webserver including PHP 7.2 |
| [whatwedo/bind](https://github.com/whatwedo/docker-base-images/tree/master/images/bind.md) | Bind9 nameserver |
| [whatwedo/docker](https://github.com/whatwedo/docker-base-images/tree/master/images/docker.md) | Docker in docker |
| [whatwedo/elasticsearch](https://github.com/whatwedo/docker-base-images/tree/master/images/elasticsearch.md) | Elasticsearch server |
| [whatwedo/gitlab-ci-multirunner](https://github.com/whatwedo/docker-base-images/tree/master/images/gitlab-ci-multi-runner.md) | GitLab CI Multirunner |
| [whatwedo/gitlab](https://github.com/whatwedo/docker-base-images/tree/master/images/gitlab.md) | GitLab |
| [whatwedo/golang](https://github.com/whatwedo/docker-base-images/tree/master/images/golang.md) | Golang compiler |
| [whatwedo/icinga2](https://github.com/whatwedo/docker-base-images/tree/master/images/icinga2.md) | Icinga2 and Icinga2-Web |
| [whatwedo/java](https://github.com/whatwedo/docker-base-images/tree/master/images/java.md) | Java 8 |
| [whatwedo/kibana](https://github.com/whatwedo/docker-base-images/tree/master/images/kibana.md) | Kibana data exploration UI |
| [whatwedo/logstash](https://github.com/whatwedo/docker-base-images/tree/master/images/logstash.md) | Logstash |
| [whatwedo/logstash-forwarder](https://github.com/whatwedo/docker-base-images/tree/master/images/logstash-forwarder.md) | Logstash-Forwarder |
| [whatwedo/mariadb](https://github.com/whatwedo/docker-base-images/tree/master/images/mariadb.md) | MariaDB server |
| [whatwedo/memcached](https://github.com/whatwedo/docker-base-images/tree/master/images/memcached.md) | memcached server |
| [whatwedo/mongodb](https://github.com/whatwedo/docker-base-images/tree/master/images/mongodb.md) | MongoDB server |
| [whatwedo/nextcloud](https://github.com/whatwedo/docker-base-images/tree/master/images/nextcloud.md) | Nextcloud server |
| [whatwedo/nginx](https://github.com/whatwedo/docker-base-images/tree/master/images/nginx.md) | nginx webserver |
| [whatwedo/nginx-php56](https://github.com/whatwedo/docker-base-images/tree/master/images/nginx-php56.md) | nginx webserver including PHP 5.6 |
| [whatwedo/nginx-php70](https://github.com/whatwedo/docker-base-images/tree/master/images/nginx-php70.md) | nginx webserver including PHP 7.0 |
| [whatwedo/nginx-php71](https://github.com/whatwedo/docker-base-images/tree/master/images/nginx-php72.md) | nginx webserver including PHP 7.1 |
| [whatwedo/nginx-php72](https://github.com/whatwedo/docker-base-images/tree/master/images/nginx-php72.md) | nginx webserver including PHP 7.2 |
| [whatwedo/node](https://github.com/whatwedo/docker-base-images/tree/master/images/node.md) | Node |
| [whatwedo/openldap](https://github.com/whatwedo/docker-base-images/tree/master/images/openldap.md) | openLDAP server |
| [whatwedo/owncloud](https://github.com/whatwedo/docker-base-images/tree/master/images/owncloud.md) | ownCloud server |
| [whatwedo/php56](https://github.com/whatwedo/docker-base-images/tree/master/images/php56.md) | PHP 5.6 interpreter |
| [whatwedo/php70](https://github.com/whatwedo/docker-base-images/tree/master/images/php70.md) | PHP 7.0 interpreter |
| [whatwedo/php71](https://github.com/whatwedo/docker-base-images/tree/master/images/php71.md) | PHP 7.1 interpreter |
| [whatwedo/php72](https://github.com/whatwedo/docker-base-images/tree/master/images/php72.md) | PHP 7.2 interpreter |
| [whatwedo/postgres](https://github.com/whatwedo/docker-base-images/tree/master/images/postgres.md) | Postgres database server |
| [whatwedo/puppet-client](https://github.com/whatwedo/docker-base-images/tree/master/images/puppet-client.md) | Puppet Client |
| [whatwedo/redis](https://github.com/whatwedo/docker-base-images/tree/master/images/redis.md) | Redis data structure server |
| [whatwedo/ruby](https://github.com/whatwedo/docker-base-images/tree/master/images/ruby.md) | Ruby interpreter |
| [whatwedo/squid](https://github.com/whatwedo/docker-base-images/tree/master/images/squid.md) | Squid proxy server |
| [whatwedo/symfony2](https://github.com/whatwedo/docker-base-images/tree/master/images/symfony2.md) | nginx configured for running Symfony 2 |
| [whatwedo/symfony3](https://github.com/whatwedo/docker-base-images/tree/master/images/symfony3.md) | nginx configured for running Symfony 3 |
| [whatwedo/symfony4](https://github.com/whatwedo/docker-base-images/tree/master/images/symfony4.md) | nginx configured for running Symfony 4 |
| [whatwedo/tomcat](https://github.com/whatwedo/docker-base-images/tree/master/images/tomcat.md) | Tomcat application server |
| [whatwedo/wordpress](https://github.com/whatwedo/docker-base-images/tree/master/images/wordpress.md) | WordPress installed on Apache 2 |
| [whatwedo/wordpress-nginx-w3tc](https://github.com/whatwedo/docker-base-images/tree/master/images/wordpress-nginx-w3tc.md) | WordPress running on nginx with PHP 7.0 and W3 Total Cache configuration |

https://github.com/whatwedo/docker-base-images/tree/master/images

## Directory/File Layout
The following table show the directory Layout of this repository:

| Folder | Description |
|---|---|
| `dist`  	| Includes all Dockerfiles and REAMDE's which are also available on [Dockerhub](https://registry.hub.docker.com/repos/whatwedo/)|
| `files` | Includes static files which are used by the Dockerfiles. For example a webserver configuration file |
| `images` | Dockerfiles and README's for the single images. All Dockerfiles are saved as `*.m4`. On this way they can include files from the `modules` folder |
| `modules`| Modules which can be included from a Dockerfile |
| `vm-init`| Files used to init the developer VM |
| `docker-builder.sh`| docker-builder.sh is a script for managing complex docker images. It provides an easy mechanism for creating and building docker images |
| `Vagrantfile`| Developer VM configuration |  

## dockerbuilder.sh
Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh). Feel free to use it in your own projects.

### Usage

```
./docker-builder.sh build-files         - This will build all dockerfiles
./docker-builder.sh build-file [name]   - This will build the given dockerfile
./docker-builder.sh build-images        - This will build all images
./docker-builder.sh build-image [name]  - This will build the given image
```

## Developer VM
To start and access the developer VM, use the following commands:

```
vagrant up
vagrant ssh
```

The repository root will be mounted under `/vagrant`

## Bugs and Issues
If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

## License
This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

## Further information
There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
