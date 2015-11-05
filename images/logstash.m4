#whatwedo apache image

include(`modules/head.m4')
include(`modules/java.m4')
include(`modules/logstash.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/opt/logstash/bin/logstash -f /etc/logstash/conf.d" >> /bin/upstart

EXPOSE 5000
