# whatwedo - Docker Base Images

[![build status](https://dev.whatwedo.ch/whatwedo/docker-base-images/badges/master/build.svg)](https://dev.whatwedo.ch/whatwedo/docker-base-images/commits/master)

We at [whatwedo](https://whatwedo.ch/) are slowly going away from traditional application hosting to the approach of using Docker containers. For this reason we built several docker images. They are available on [Dockerhub](https://registry.hub.docker.com/repos/whatwedo/). You can use them easily in your own projects.

## Images
| Name | Description |
|---|---|
| [whatwedo/base](https://github.com/whatwedo/docker-base-images/tree/master/dist/base/) | several base packages for daily working with docker installed |
| [whatwedo/apache](https://github.com/whatwedo/docker-base-images/tree/master/dist/apache/) | Apache 2 webserver |
| [whatwedo/apache-php56](https://github.com/whatwedo/docker-base-images/tree/master/dist/apache-php56/) | Apache 2 webserver including PHP 5.6 |
| [whatwedo/apache-php70](https://github.com/whatwedo/docker-base-images/tree/master/dist/apache-php70/) | Apache 2 webserver including PHP 7.0 |
| [whatwedo/bind](https://github.com/whatwedo/docker-base-images/tree/master/dist/bind/) | Bind9 nameserver |
| [whatwedo/docker](https://github.com/whatwedo/docker-base-images/tree/master/dist/docker/) | Docker in docker |
| [whatwedo/elasticsearch](https://github.com/whatwedo/docker-base-images/tree/master/dist/elasticsearch/) | Elasticsearch server |
| [whatwedo/gitlab-ci-multirunner](https://github.com/whatwedo/docker-base-images/tree/master/dist/gitlab-ci-multi-runner/) | GitLab CI Multirunner |
| [whatwedo/gitlab](https://github.com/whatwedo/docker-base-images/tree/master/dist/gitlab/) | GitLab |
| [whatwedo/golang](https://github.com/whatwedo/docker-base-images/tree/master/dist/golang/) | Golang compiler |
| [whatwedo/icinga2](https://github.com/whatwedo/docker-base-images/tree/master/dist/icinga2/) | Icinga2 and Icinga2-Web |
| [whatwedo/java](https://github.com/whatwedo/docker-base-images/tree/master/dist/java/) | Java 8 |
| [whatwedo/kibana](https://github.com/whatwedo/docker-base-images/tree/master/dist/kibana/) | Kibana data exploration UI |
| [whatwedo/logstash](https://github.com/whatwedo/docker-base-images/tree/master/dist/logstash/) | Logstash |
| [whatwedo/logstash-forwarder](https://github.com/whatwedo/docker-base-images/tree/master/dist/logstash-forwarder/) | Logstash-Forwarder |
| [whatwedo/mariadb](https://github.com/whatwedo/docker-base-images/tree/master/dist/mariadb/) | MariaDB server |
| [whatwedo/memcached](https://github.com/whatwedo/docker-base-images/tree/master/dist/memcached/) | memcached server |
| [whatwedo/mongodb](https://github.com/whatwedo/docker-base-images/tree/master/dist/mongodb/) | MongoDB server |
| [whatwedo/nextcloud](https://github.com/whatwedo/docker-base-images/tree/master/dist/nextcloud/) | Nextcloud server |
| [whatwedo/nginx](https://github.com/whatwedo/docker-base-images/tree/master/dist/nginx/) | nginx webserver |
| [whatwedo/nginx-php56](https://github.com/whatwedo/docker-base-images/tree/master/dist/nginx-php56/) | nginx webserver including PHP 5.6 |
| [whatwedo/nginx-php70](https://github.com/whatwedo/docker-base-images/tree/master/dist/nginx-php70/) | nginx webserver including PHP 7.0 |
| [whatwedo/node](https://github.com/whatwedo/docker-base-images/tree/master/dist/node/) | Node |
| [whatwedo/owncloud](https://github.com/whatwedo/docker-base-images/tree/master/dist/owncloud/) | ownCloud server |
| [whatwedo/php56](https://github.com/whatwedo/docker-base-images/tree/master/dist/php56/) | PHP 5.6 interpreter |
| [whatwedo/php70](https://github.com/whatwedo/docker-base-images/tree/master/dist/postgres/) | PHP 7.0 interpreter |
| [whatwedo/postgres](https://github.com/whatwedo/docker-base-images/tree/master/dist/postgres/) | Postgres database server |
| [whatwedo/puppet-client](https://github.com/whatwedo/docker-base-images/tree/master/dist/puppet-client/) | Puppet Client |
| [whatwedo/redis](https://github.com/whatwedo/docker-base-images/tree/master/dist/redis/) | Redis data structure server |
| [whatwedo/ruby](https://github.com/whatwedo/docker-base-images/tree/master/dist/ruby/) | Ruby interpreter |
| [whatwedo/squid](https://github.com/whatwedo/docker-base-images/tree/master/dist/squid/) | Squid proxy server |
| [whatwedo/symfony2](https://github.com/whatwedo/docker-base-images/tree/master/dist/symfony2/) | nginx configured for running Symfony 2 |
| [whatwedo/symfony3](https://github.com/whatwedo/docker-base-images/tree/master/dist/symfony3/) | nginx configured for running Symfony 3 |
| [whatwedo/tomcat](https://github.com/whatwedo/docker-base-images/tree/master/dist/tomcat/) | Tomcat application server |
| [whatwedo/wordpress](https://github.com/whatwedo/docker-base-images/tree/master/dist/wordpress/) | WordPress installed on Apache 2 |
| [whatwedo/wordpress-nginx-w3tc](https://github.com/whatwedo/docker-base-images/tree/master/dist/wordpress-nginx-w3tc/) | WordPress running on nginx with PHP 7.0 and W3 Total Cache configuration |


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
