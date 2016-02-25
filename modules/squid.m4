#Install PHP
RUN apt-get install squid -y

# Add squid to supervisord config
COPY files/supervisord/squid.conf /etc/supervisor/conf.d/squid.conf
