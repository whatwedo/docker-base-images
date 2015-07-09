#whatwedo Redis image

include(`modules/head.m4')
include(`modules/redis.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/usr/bin/redis-server" >> /bin/upstart

#Expose Ports
EXPOSE 6379

#Create volumes
VOLUME  ["/var/redis"]
