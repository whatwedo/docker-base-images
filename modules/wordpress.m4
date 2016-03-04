#Download and install Wordpress
RUN wget https://de.wordpress.org/latest-de_DE.zip
RUN unzip latest-de_DE.zip
RUN rm latest-de_DE.zip
RUN cp -r wordpress/* /var/www/html
RUN rm -rf wordpress
RUN chown -R www-data:www-data /var/www