#whatwedo symfony image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php.m4')
include(`modules/cleanup.m4')

#Set config
RUN rm /etc/nginx/nginx.conf
ADD files/symfony /etc/nginx

#Expose Ports
EXPOSE 80
EXPOSE 443

#Add symfony logs to supervisord config
COPY files/supervisord/symfony.conf /etc/supervisor/conf.d/symfony.conf