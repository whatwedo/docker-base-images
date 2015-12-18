# Install redis-server
RUN apt-get install -y redis-server
RUN mkdir /var/data
RUN echo "dir /var/data" >> /etc/redis/redis.conf

#Add redis to supervisord config
COPY files/supervisord/redis.conf /etc/supervisor/conf.d/redis.conf