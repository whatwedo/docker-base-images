#whatwedo - Docker Base Images
We at [whatwedo](https://whatwedo.ch/) are slowly going away from traditional application hosting to the approach of using Docker containers. For this reason we built several docker images. They are available on [Dockerhub](https://registry.hub.docker.com/repos/whatwedo/). You can use them easily in your own projects.

##Images
| Name | Description |
|---|---|
| [base](https://registry.hub.docker.com/u/whatwedo/base/) | several base packages for daily working with docker installed |
| [bind](https://registry.hub.docker.com/u/whatwedo/bind/) | Bind9 nameserver |
| [golang](https://registry.hub.docker.com/u/whatwedo/golang/) | Golang compiler |
| [mariadb](https://registry.hub.docker.com/u/whatwedo/mariadb/) | MariaDB server |
| [nginx](https://registry.hub.docker.com/u/whatwedo/nginx/) | nginx webserver |
| [postgres](https://registry.hub.docker.com/u/whatwedo/postgres/) | Postgres database server |
| [tomcat](https://registry.hub.docker.com/u/whatwedo/tomcat/) | Tomcat application server |

##Directory/File Layout
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

##dockerbuilder.sh
Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh). Feel free to use it in your own projects.

###Usage

```
./docker-builder.sh build-files         - This will build all dockerfiles
./docker-builder.sh build-file [name]   - This will build the given dockerfile
./docker-builder.sh build-images        - This will build all images
./docker-builder.sh build-image [name]  - This will build the given image
```

##Developer VM
To start and access the developer VM, use the following commands:

```
vagrant up
vagrant ssh
```

The repository root will be mounted under `/vagrant`

##Bugs and Issues
If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

##License
This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

##Further information
There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).