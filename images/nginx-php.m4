#whatwedo nginx php image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/php.m4')
include(`modules/cleanup.m4')

#Set config
RUN rm /etc/nginx/nginx.conf
ADD files/nginx-php /etc/nginx

#Alter upstart script
RUN echo -n "service php5-fpm start && nginx" >> /bin/upstart

#Expose Ports
EXPOSE 80
EXPOSE 443

#Create volumes
VOLUME  ["/var/www"]