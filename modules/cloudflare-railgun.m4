# Add railgun repo
RUN wget --quiet -O - https://pkg.cloudflare.com/pubkey.gpg | apt-key add -
RUN echo "deb http://pkg.cloudflare.com/ trusty main" >> /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get install -y railgun-stable

# Configuration
RUN echo 'sed -i s/^memcached\.servers.*/memcached\.servers\ =\ ${MEMCACHED_SERVERS}/g /etc/railgun/railgun.conf' >> /bin/everyboot
RUN echo 'sed -i s/^activation\.token.*/activation\.token\ =\ ${ACTIVATION_TOKEN}/g /etc/railgun/railgun.conf' >> /bin/everyboot
RUN echo 'sed -i s/^activation\.railgun_host.*/activation\.railgun_host\ =\ ${ACTIVATION_RAILGUN_HOST}/g /etc/railgun/railgun.conf' >> /bin/everyboot

# Log files
RUN touch /var/log/railgun/panic.log

# Add default supervisord config
COPY files/supervisord/cloudflare-railgun.conf /etc/supervisor/conf.d/cloudflare-railgun.conf
