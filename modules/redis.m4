# Install redis-server
RUN apt-get install -y redis-server
RUN mkdir /var/data
RUN echo "dir /var/data" >> /etc/redis/redis.conf
