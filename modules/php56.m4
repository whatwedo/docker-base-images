#Add PPA
RUN add-apt-repository -y ppa:ondrej/php5-5.6
RUN apt-get update

#Install PHP
RUN apt-get install php5-cli php5-common php5-cgi php5-curl php5-imagick php5-imap php5-pgsql php5-sqlite php5-mysql php5-fpm php5-mcrypt php5-ldap php5-json php5-intl php5-gd -y

#Set php.ini defaults
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "php_flag[expose_php] = Off" >> /etc/php/7.0/fpm/pool.d/www.conf

#Fix session permission error
RUN chmod -R 777 /var/lib/php5
