#whatwedo apache image

include(`modules/head.m4')
include(`modules/java.m4')
include(`modules/elasticsearch.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 9200
EXPOSE 9300

#Create volumes
VOLUME  ["/data"]