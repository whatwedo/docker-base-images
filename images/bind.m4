#whatwedo Bind9 image

include(`modules/head.m4')
include(`modules/bind9.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/usr/sbin/named -g -c /etc/bind/named.conf -u bind" >> /bin/upstart

#Expose Ports
EXPOSE 53/udp 53/tcp
EXPOSE 953