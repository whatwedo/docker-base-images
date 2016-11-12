# Add icinga repo
RUN wget --quiet -O - http://packages.icinga.org/icinga.key | apt-key add -
RUN echo "deb http://packages.icinga.org/ubuntu icinga-trusty main" >> /etc/apt/sources.list
RUN apt-get update -y

# Install icinga and nagios plugins
RUN apt-get -y install icinga2 icinga2-ido-mysql icinga2-classicui nagios-plugins icingaweb2 nmap php-htmlpurifier php5.6-dom
RUN apt-get -y install nagios-nrpe-plugin --no-install-recommends

# Enable features
RUN icinga2 feature enable ido-mysql
RUN icinga2 feature enable command

# Add nagios plugins
ADD files/icinga/plugins /usr/lib/nagios/plugins
RUN chmod 755 /usr/lib/nagios/plugins/check_rbl
RUN chmod 755 /usr/lib/nagios/plugins/check_senderscore
RUN chmod 755 /usr/lib/nagios/plugins/check_open_ports
RUN chmod 755 /usr/lib/nagios/plugins/check_symfony

# Add Slack integration
RUN apt-get -y install libwww-perl libcrypt-ssleay-perl
RUN wget https://raw.github.com/tinyspeck/services-examples/master/nagios.pl
RUN mv nagios.pl /usr/local/bin/slack_nagios.pl
RUN chmod 755 /usr/local/bin/slack_nagios.pl

# Add www-data user to icingaweb2 group
RUN addgroup --system icingaweb2
RUN usermod -a -G icingaweb2 www-data

# Start and stop icinga (Init system)
RUN /etc/init.d/icinga2 start && sleep 30 && /etc/init.d/icinga2 stop

# Auto redirect to icinga-web
RUN echo '<?php header("location: /icingaweb2"); ?>' > /var/www/html/index.php

# Set timezone
RUN echo 'echo date.timezone = ${CONTAINER_TIMEZONE:=Europe/Zurich} >> /etc/php/5.6/apache2/php.ini' >> /bin/everyboot

# Generate setup token
RUN echo "icingacli setup config directory --group icingaweb2" >> /bin/everyboot
RUN echo 'echo "---------------------------------------------------"' >> /bin/firstboot
RUN echo 'test "$(ls -A /etc/icinga2)" || cp -a /etc/icinga2_copy/. /etc/icinga2/' >> /bin/firstboot
RUN echo 'test "$(ls -A /etc/icingaweb2)" || cp -a /etc/icingaweb2_copy/. /etc/icingaweb2/' >> /bin/firstboot
RUN echo 'test "$(ls -A /var/lib/icinga2)" || cp -a /var/lib/icinga2_copy/. /var/lib/icinga2/' >> /bin/firstboot
RUN echo 'test "$(ls -A /etc/icinga2-classicui)" || cp -a /etc/icinga2-classicui_copy/. /etc/icinga2-classicui/' >> /bin/firstboot
RUN echo "icingacli setup token create" >> /bin/firstboot
RUN echo 'echo "---------------------------------------------------"' >> /bin/firstboot
RUN echo "chgrp -R icingaweb2 /etc/icingaweb2/setup.token" >> /bin/firstboot
RUN echo "chmod -R 777 /etc/icingaweb2" >> /bin/firstboot

# db-config settings
RUN echo 'echo "dbc_install=\"true\"" > /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_upgrade=\"true\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_remove=\"\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbtype=\"mysql\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_ssl=\"\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbadmin=\"root\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_basepath=\"\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_authmethod_admin=\"\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_authmethod_user=\"\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbuser=\"${DB_USER}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbpass=\"${DB_PW}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbserver=\"${DB_SERVER}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbport=\"${DB_PORT}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "dbc_dbname=\"${DB_NAME}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/everyboot

# Icinga db settings
RUN echo 'echo "library \"db_ido_mysql\"" > /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "object IdoMysqlConnection \"ido-mysql\" {" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "user = \"${DB_USER}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "password = \"${DB_PW}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "host = \"${DB_SERVER}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "port = \"${DB_PORT}\"" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "database = \"${DB_NAME}\"" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot
RUN echo 'echo "}" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/everyboot

# Icinga classicui settings
RUN echo 'rm -f /etc/icinga2-classicui/htpasswd.users && htpasswd -b -c /etc/icinga2-classicui/htpasswd.users icingaadmin ${ICINGAADMIN_PW}' >> /bin/everyboot

# Wait until database service is started (in multi container environement)
RUN echo 'sleep 30' >> /bin/firstboot
RUN echo 'mysql -u ${DB_USER} -p${DB_PW} -h ${DB_SERVER} -P ${DB_PORT} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"' >> /bin/firstboot
RUN echo 'mysql -u ${DB_USER} -p${DB_PW} -h ${DB_SERVER} -D ${DB_NAME} -P ${DB_PORT} < /usr/share/icinga2-ido-mysql/schema/mysql.sql' >> /bin/firstboot

# Add apache to icinga2 config
COPY files/supervisord/icinga2.conf /etc/supervisor/conf.d/icinga2.conf

# Copy default config files
RUN cp -a /etc/icinga2 /etc/icinga2_copy
RUN cp -a /etc/icingaweb2 /etc/icingaweb2_copy
RUN cp -a /var/lib/icinga2 /var/lib/icinga2_copy
RUN cp -a /etc/icinga2-classicui /etc/icinga2-classicui_copy

