# Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).


## v1.4.1 - 2016-12-18

### Features

* Build: Enabled push for all images


## v1.4.0 - 2016-12-18

### Features

* Build: Added possibility to build image on gitlab ci
* Build: Squash image to one layer


## v1.3.0 - 2016-12-18

### Features

* whatwedo/nextcloud: added nexcloud image


## v1.2.6 - 2016-12-12

### Bugfixes

* whatwedo/gitlab: fixed background workers


## v1.2.5 - 2016-12-06

### Bugfixes

* whatwedo/gitlab: update ruby to v2.3.3

## v1.2.4 - 2016-12-05

### Bugfixes

* Core: Added Editorconfig
* whatwedo/apache-php56: Added missing php5.6-xml, php5.6-mbstring and php5.6-dom
* whatwedo/icinga2: Added missing php5.6-xml, php5.6-mbstring and php5.6-dom
* whatwedo/nginx-php56: Added missing php5.6-xml, php5.6-mbstring and php5.6-dom
* whatwedo/php56: Added missing php5.6-xml, php5.6-mbstring and php5.6-dom
* whatwedo/symfony2: Added missing php5.6-xml, php5.6-mbstring and php5.6-dom

## v1.2.3 - 2016-12-05

### Bugfixes

* whatwedo/gitlab: Fixing hooks_path


## v1.2.2 - 2016-11-23

### Features

* whatwedo/gitlab: Updated Gitlab to v8.14.0


## v1.2.1 - 2016-11-16

### Bugfixes

* whatwedo/symfony2: disable downloading node.js by ssl [because of SNI support](https://github.com/nodesource/distributions/issues/353) for nodesource.com
* whatwedo/symfony3: disable downloading node.js by ssl [because of SNI support](https://github.com/nodesource/distributions/issues/353) for nodesource.com
* whatwedo/node: disable downloading node.js by ssl [because of SNI support](https://github.com/nodesource/distributions/issues/353) for nodesource.com


## v1.2.0 - 2016-11-16

### Features

* whatwedo/mariadb: Add parameter `INNODB_BUFFER_POOL_SIZE`
* whatwedo/mariadb: Use MariaDB 10.1 with sources in Amsterdam instead of NYC

## v1.1.14 - 2016-11-14


### Features

* whatwedo/gitlab: Updated Gitlab to v8.13.5


## v1.1.13 - 2016-11-12

### Bugfixes

* whatwedo/icinga2: Fixed PHP timezone #8
* whatwedo/icinga2: Added PHP DOM 5.6


## v1.1.12 - 2016-11-11

### Features

* whatwedo/wordpress: Updated to PHP 7.0


### Bugfixes

* whatwedo/apache-php56: Fixed PPA issue
* whatwedo/icinga2: Fixed PPA issue
* whatwedo/nginx-php56: Fixed PPA issue
* whatwedo/php56: Fixed PPA issue
* whatwedo/symfony2: Fixed PPA issue


## v1.1.11 - 2016-11-11

### Bugfixes

* whatwedo/gitlab: Added secret keys to volume


## v1.1.10 - 2016-11-09

### Features

* whatwedo/gitlab: Updated Gitlab to v8.13.3


## v1.1.9 - 2016-11-01

### Features

* whatwedo/gitlab: Updated Gitlab to v8.13.2


## v1.1.8 - 2016-10-26

### Features

* whatwedo/owncloud: Update ownCloud automatically to latest stable version


## v1.1.7 - 2016-10-26

### Bugfixes

* whatwedo/icinga2: Fixed #3 - Config directories will get initialized properly
* whatwedo/icinga2: Fixed Dcokerfile command formatting



## v1.1.6 - 2016-10-26

### Features

* whatwedo/gitlab: Updated Gitlab to v8.13.1


## Bugixes

* Removed output of `/var/log/messages`


## v1.1.5 - 2016-10-24

### Features

* whatwedo/gitlab: Updated Gitlab to v8.13.0
* whatwedo/gitlab: Updated git to v2.10.1
* whatwedo/gitlab: Updated golang to v1.7.3
* whatwedo/gitlab: Updated docker-machine to v0.8.2
* whatwedo/gitlab-ci-multi-runner: Updated Gitlab CI Multirunner to 1.7.0


## v1.1.4 - 2016-09-16

### Features

* whatwedo/gitlab: Updated Gitlab to v8.11.6


## v1.1.3 - 2016-08-25

### Features

* whatwedo/gitlab: Updated Gitlab to v8.11.2


## v1.1.2 - 2016-08-23

### Features

* whatwedo/gitlab: Updated Gitlab to v8.11.0


## v1.1.1 - 2016-08-02

### Features

* whatwedo/gitlab: Updated Gitlab to v8.10.3


## v1.1.0 - 2016-07-26

### Features

* whatwedo/cloudflare-railgun: Added Cloudflare Railgun image


### Bugixes

* whatwedo/gitlab-ci-multi-runner: Remove certificates on container startup


## v1.0.0 - 2016-07-15

**Initial versioned release.**
