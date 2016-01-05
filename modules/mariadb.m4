# Edit sources
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu trusty main'
RUN apt-get update

# Install MariaDB
RUN apt-get install -y mariadb-server

# Default Config
RUN sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
sed -i 's/log_bin/#log_bin/g' /etc/mysql/my.cnf && \
sed -i 's/expire_logs_days/#expire_logs_days/g' /etc/mysql/my.cnf && \
sed -i 's/max_binlog_size/#max_binlog_size/g' /etc/mysql/my.cnf && \
sed -i 's/#innodb_log_file_size.*/innodb_log_file_size\=256M/g' /etc/mysql/my.cnf

# Edit firstboot script
RUN echo "mkdir -p /var/lib/mysql" >> /bin/firstboot
RUN echo "chown -R mysql:mysql /var/lib/mysql" >> /bin/firstboot
RUN echo "mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm" >> /bin/firstboot
RUN echo "mysqld_safe & mysqladmin --silent --wait=30 ping || exit 1" >> /bin/firstboot
RUN echo 'echo "DELETE FROM mysql.user;" >> /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'echo "CREATE USER \"root\"@\"%\" IDENTIFIED BY \"${MYSQL_ROOT_PASSWORD}\" ;" >> /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'echo "GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;" >> /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'echo "FLUSH PRIVILEGES;" >> /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'echo "DROP DATABASE IF EXISTS test;" >> /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'if [ ! -z "${MYSQL_DATABASE}" ]; then echo "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" >> /root/mysql-first-time.sql; fi' >> /bin/firstboot
RUN echo 'mysql < /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'rm /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'mysqladmin shutdown -uroot -p${MYSQL_ROOT_PASSWORD}' >> /bin/firstboot

# Add mariadb to supervisord config
COPY files/supervisord/mariadb.conf /etc/supervisor/conf.d/mariadb.conf