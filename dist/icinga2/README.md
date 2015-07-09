#whatwedo base image - Icinga2
In this image is a basic Icinga-Core and Icinga-Web installation including Nagios plugins available. 

You need a seperate [MySQL or MariaDB](https://registry.hub.docker.com/u/whatwedo/mariadb/) database to run this container.

##Usage

```
docker run -p 80:80 -e DB_USER=root -e DB_PW=mysecretpassword -e DB_SERVER=db -e DB_PORT=3306 -e DB_NAME= -e MYSQL_ROOT_PASSWORD=icinga-ido  whatwedo/icinga2
```

##Environment Variables
Every of the following environment variables is required

###DB_USER
User of thy Icinga2 mysql-ido database. In the above example, it is being set to "root".

###DB_PW
Passowrd of thy Icinga2 mysql-ido database. In the above example, it is being set to "mysecretpassword".

###DB_SERVER
Server of thy Icinga2 mysql-ido database. In the above example, it is being set to "db".

###DB_PORT
Post of thy Icinga2 mysql-ido database. In the above example, it is being set to "3306".

###DB_NAME
Name of thy Icinga2 mysql-ido database. In the above example, it is being set to "icinga-ido".

##Volumes
* /etc/icinga2
* /etc/icingaweb2

##Exposed Ports
* 80

##Built
Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh)

##Bugs and Issues
If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

##License
This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

##Further information
There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).