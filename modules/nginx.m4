#Install nginx
RUN apt-get update
RUN apt-get install -y nginx libpcre3-dev libssl-dev zlib1g-dev

#Create required directories and files
RUN touch /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log
RUN mkdir /etc/nginx/ssl
RUN chown -R www-data:www-data /var/lib/nginx

#Edit config
RUN mkdir /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod -R 2755 /var/www/
RUN rm -rf /etc/nginx/sites-available/
RUN rm -rf /etc/nginx/sites-enabled/
RUN rm -rf /etc/nginx/conf.d/
RUN rm /etc/nginx/nginx.conf
ADD files/nginx-default /etc/nginx

