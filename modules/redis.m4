# Install redis-server
RUN apt-get install -y redis-server
RUN mkdir /var/data

RUN sed -i s@^daemonize\ .*@daemonize\ no@g /etc/redis/redis.conf
RUN sed -i s@^dir\ .*@dir\ /var/data/@g /etc/redis/redis.conf
RUN sed -i s/^bind\ .*$/bind\ 0\.0\.0\.0/g /etc/redis/redis.conf

# Add redis to supervisord config
COPY files/supervisord/redis.conf /etc/supervisor/conf.d/redis.conf
