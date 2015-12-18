#Add logstash repo
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN add-apt-repository 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main'
RUN apt-get update -y

#Install Logstash
RUN apt-get install -y logstash

#Add logstash to supervisord config
COPY files/supervisord/logstash.conf /etc/supervisor/conf.d/logstash.conf