# whatwedo symfony image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php70.m4')
include(`modules/node.m4')

# Set config
RUN rm /etc/nginx/nginx.conf
ADD files/symfony3 /etc/nginx

# Add php-fpm to supervisord config
COPY files/supervisord/php-fpm70.conf /etc/supervisor/conf.d/php-fpm70.conf

# Add symfony logs to supervisord config
COPY files/supervisord/symfony3.conf /etc/supervisor/conf.d/symfony3.conf

# Clean cache on startup
RUN echo 'php bin/console cache:clear --env=prod' >> /bin/everyboot

# Expose Ports
EXPOSE 80
EXPOSE 443

include(`modules/cleanup.m4')