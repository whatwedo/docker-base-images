# Add PPA
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

# Install PHP
RUN apt-get install php5.6-cli php5.6-common php5.6-cgi php5.6-curl php5.6-imagick php5.6-imap php5.6-pgsql php5.6-sqlite php5.6-mysql php5.6-fpm php5.6-mcrypt php5.6-ldap php5.6-json php5.6-intl php5.6-gd php5.6-xml php5.6-mbstring php5.6-dom -y

# Set php.ini defaults
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php/5.6/fpm/php.ini
RUN echo "php_flag[expose_php] = Off" >> /etc/php/5.6/fpm/pool.d/www.conf
RUN echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php/5.6/fpm/pool.d/www.conf
RUN echo "php_admin_value[post_max_size] = 32M" >> /etc/php/5.6/fpm/pool.d/www.conf
RUN echo "php_flag[display_errors] = off" >> /etc/php/5.6/fpm/pool.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /etc/php/5.6/fpm/pool.d/www.conf
RUN echo "php_flag[expose_php] = Off" >> /etc/php/5.6/fpm/pool.d/www.conf

# Fix session permission error
RUN chmod -R 777 /var/lib/php/sessions