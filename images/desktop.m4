#whatwedo desktop image

include(`modules/head.m4')
include(`modules/git.m4')
include(`modules/desktop.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 6080

#Alter upstart script
RUN echo -n "exec /usr/bin/supervisord -n" >> /bin/upstart