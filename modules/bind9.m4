#Install bind9
RUN apt-get install -y bind9
RUN mkdir -p /var/run/named && chown bind:bind /var/run/named

#Add bind to supervisord config
COPY files/supervisord/bind.conf /etc/supervisor/conf.d/bind.conf