#whatwedo Redis image

include(`modules/head.m4')
include(`modules/redis.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 6379

#Create volumes
VOLUME  ["/var/redis"]
