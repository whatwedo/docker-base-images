# Install deps
RUN apt-get install -y memcached

# add supervisord config
COPY files/supervisord/memcached.conf /etc/supervisor/conf.d/memcached.conf
