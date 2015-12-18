#whatwedo Bind9 image

include(`modules/head.m4')
include(`modules/bind9.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 53/udp 53/tcp
EXPOSE 953