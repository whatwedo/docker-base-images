#whatwedo apache image

include(`modules/head.m4')
include(`modules/apache.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 80
EXPOSE 443

#Create volumes
VOLUME  ["/var/www"]