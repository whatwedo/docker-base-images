#whatwedo MariaDB image

include(`modules/head.m4')
include(`modules/mariadb.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/usr/sbin/mysqld" >> /bin/upstart

#Set volumes
VOLUME ["/var/lib/mysql"]

#Expose Ports
EXPOSE 3306