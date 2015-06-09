#whatwedo apache image

include(`modules/head.m4')
include(`modules/apache.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "apache2 -D FOREGROUND" >> /bin/upstart

#Expose Ports
EXPOSE 80

#Create volumes
VOLUME  ["/var/www"]