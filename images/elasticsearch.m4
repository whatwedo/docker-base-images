#whatwedo apache image

include(`modules/head.m4')
include(`modules/java.m4')
include(`modules/elasticsearch.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/usr/share/elasticsearch/bin/elasticsearch" >> /bin/upstart

#Expose Ports
EXPOSE 9200
EXPOSE 9300

#Create volumes
VOLUME  ["/data]