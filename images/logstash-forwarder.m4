#whatwedo logstash-forwarder image

include(`modules/head.m4')
include(`modules/golang.m4')
include(`modules/git.m4')
include(`modules/logstash-forwarder.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/opt/logstash-forwarder/logstash-forwarder -config /etc/logstash-forwarder/config.json" >> /bin/upstart