#Add elasticsearch repo
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
RUN add-apt-repository 'deb http://packages.elasticsearch.org/elasticsearch/1.6/debian stable main'
RUN apt-get update -y

#Install Elasticsearch
RUN apt-get -y install elasticsearch

#Add config
RUN rm -rf /etc/elasticsearch/elasticsearch.yml
ADD files/elasticsearch /etc/elasticsearch

#Link config dir
RUN ln -s /etc/elasticsearch /usr/share/elasticsearch/config

#Add elasticsearch to supervisord config
COPY files/supervisord/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf