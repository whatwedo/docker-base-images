#whatwedo kibana image

include(`modules/head.m4')
include(`modules/kibana.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n 'kibana -e ${ELASTICSEARCH_URL}' >> /bin/upstart

#Expose Ports
EXPOSE 3306