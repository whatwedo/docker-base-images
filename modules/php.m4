#Install PHP
RUN apt-get install php5-cli php5-common php5-cgi php5-curl php5-imagick php5-imap php5-pgsql php5-sqlite php5-mysql php5-fpm php5-mcrypt -y
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini

#Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer