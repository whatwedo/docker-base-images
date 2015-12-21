#whatwedo nginx php image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php70.m4')
include(`modules/cleanup.m4')

#Set config
RUN rm /etc/nginx/nginx.conf
ADD files/nginx-php70 /etc/nginx

#Add php-fpm to supervisord config
COPY files/supervisord/php-fpm70.conf /etc/supervisor/conf.d/php-fpm70.conf

#Expose Ports
EXPOSE 80
EXPOSE 443
