#whatwedo nginx php image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php71.m4')
include(`modules/cleanup.m4')

#Set config
RUN rm /etc/nginx/nginx.conf
ADD files/nginx-php71 /etc/nginx

#Add php-fpm to supervisord config
COPY files/supervisord/php-fpm71.conf /etc/supervisor/conf.d/php-fpm71.conf

#Expose Ports
EXPOSE 80
EXPOSE 443
