#Download and build logstash-forwarder
RUN git clone git://github.com/elasticsearch/logstash-forwarder.git /opt/logstash-forwarder
RUN cd /opt/logstash-forwarder && go build

#Add logstash-forwarder to supervisord config
COPY files/supervisord/logstash-forwarder.conf /etc/supervisor/conf.d/logstash-forwarder.conf