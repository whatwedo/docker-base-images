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
echo "mysqld_safe &" > /tmp/config && \
echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
echo "mysql -e 'DROP DATABASE IF EXISTS test'" >> /tmp/config && \
bash /tmp/config && \
rm -f /tmp/config && \
/etc/init.d/mysql stop

# Edit firstboot script
RUN echo "/etc/init.d/mysql start && sleep 10" >> /bin/firstboot
RUN echo 'echo "SET PASSWORD FOR \"root\"@\"%\" = PASSWORD(\"${MYSQL_ROOT_PASSWORD}\");" > /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'mysql -u root < /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo 'rm /root/mysql-first-time.sql' >> /bin/firstboot
RUN echo "/etc/init.d/mysql stop && sleep 10" >> /bin/firstboot

# Add mariadb to supervisord config
COPY files/supervisord/mariadb.conf /etc/supervisor/conf.d/mariadb.conf