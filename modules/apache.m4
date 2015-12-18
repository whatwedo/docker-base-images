#Install apache and openssl
RUN apt-get install -y apache2

#Apache settings
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

#Remove default files
RUN rm -rf /var/www/html/*

#Set permissions
RUN chown -R www-data /var/www/
RUN chmod -R 755 /var/www/

#Create start script
RUN echo "#\0041/bin/bash" > /bin/start-apache
RUN echo "rm -rf /run/httpd/*" >> /bin/start-apache
RUN echo "apache2 -D FOREGROUND" >> /bin/start-apache
RUN chmod 755 /bin/start-apache

#Create log files
RUN touch /var/log/apache2/access.log && chown /var/log/apache2/access.log www-data
RUN touch /var/log/apache2/error.log && chown /var/log/apache2/error.log www-data

#Add apache to supervisord config
COPY files/supervisord/apache.conf /etc/supervisor/conf.d/apache.conf