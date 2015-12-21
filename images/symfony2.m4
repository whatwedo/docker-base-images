#whatwedo symfony image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php56.m4')
include(`modules/cleanup.m4')

#Set config
RUN rm /etc/nginx/nginx.conf
ADD files/symfony2 /etc/nginx

#Add php-fpm to supervisord config
COPY files/supervisord/php-fpm56.conf /etc/supervisor/conf.d/php-fpm56.conf

#Add symfony logs to supervisord config
COPY files/supervisord/symfony2.conf /etc/supervisor/conf.d/symfony2.conf

#Expose Ports
EXPOSE 80
EXPOSE 443