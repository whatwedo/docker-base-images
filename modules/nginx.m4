#Install nginx
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x7BD9BF62
RUN add-apt-repository 'deb http://nginx.org/packages/mainline/ubuntu trusty nginx'
RUN apt-get update
RUN apt-get install -y nginx

#Create required directories and files
RUN touch /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log

#Edit config
RUN mkdir /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod -R 2755 /var/www/
RUN rm -rf /etc/nginx/sites-available/
RUN rm -rf /etc/nginx/sites-enabled/
RUN rm -rf /etc/nginx/conf.d/
RUN rm /etc/nginx/nginx.conf
ADD files/nginx-default /etc/nginx

#Set permissions
RUN chown -R www-data /var/www/
RUN chmod -R 755 /var/www/

#Add apache to supervisord config
COPY files/supervisord/nginx.conf /etc/supervisor/conf.d/nginx.conf