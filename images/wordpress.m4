#whatwedo worpress image

include(`modules/head.m4')
include(`modules/apache.m4')
include(`modules/php56.m4')

#Install mod_php
RUN apt-get install -y libapache2-mod-php7.0

include(`modules/wordpress.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 80

#Create volumes
VOLUME  ["/var/www"]