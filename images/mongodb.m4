#whatwedo MongoDB image

include(`modules/head.m4')
include(`modules/mongodb.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 27017

#Create volumes
VOLUME  ["/data"]