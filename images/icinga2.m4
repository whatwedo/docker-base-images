#whatwedo Icinga2 image

include(`modules/head.m4')
include(`modules/apache.m4')
include(`modules/php.m4')

#Install mod_php
RUN apt-get install -y libapache2-mod-php5

include(`modules/icinga2.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "rm -rf /run/httpd/* && /usr/sbin/icinga2 daemon & apache2 -D FOREGROUND" >> /bin/upstart

#Create volumes
VOLUME  ["/etc/icinga2", "/etc/icingaweb2", "/var/lib/icinga2"]