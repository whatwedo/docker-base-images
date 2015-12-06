#whatwedo apache image

include(`modules/head.m4')
include(`modules/apache.m4')
include(`modules/php.m4')

#Install mod_php
RUN apt-get install -y libapache2-mod-php5

include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "rm -rf /run/httpd/* && apache2 -D FOREGROUND" >> /bin/upstart

#Expose Ports
EXPOSE 80
EXPOSE 443
