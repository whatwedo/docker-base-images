# whatwedo nginx w3 total cache
include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php70.m4')
include(`modules/memcached.m4')
include(`modules/cleanup.m4')

# set config
RUN rm /etc/nginx/nginx.conf
ADD files/wordpress-nginx-w3tc/nginx.conf /etc/nginx/nginx.conf
ADD files/wordpress-nginx-w3tc/crontab /tmp/crontab

# add supervisord config
COPY files/supervisord/php-fpm70.conf /etc/supervisor/conf.d/php-fpm70.conf

# set cronjobs
RUN crontab /tmp/crontab

RUN echo "chown -R www-data:www-data /var/www" >> /bin/everyboot

# Expose Ports
EXPOSE 80
EXPOSE 443
