#Edit sources
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu trusty main'
RUN apt-get update

#Install MariaDB
RUN apt-get install -y mariadb-server

#Default Config
RUN sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
echo "mysqld_safe &" > /tmp/config && \
echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
bash /tmp/config && \
rm -f /tmp/config