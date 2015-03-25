#whatwedo nginx image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "nginx" >> /bin/upstart

#Expose Ports
EXPOSE 80