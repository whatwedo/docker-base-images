#Add icinga repo
RUN wget --quiet -O - http://packages.icinga.org/icinga.key | apt-key add -
RUN echo "deb http://packages.icinga.org/ubuntu icinga-trusty main" >> /etc/apt/sources.list
RUN apt-get update -y

#Install icinga and nagios plugins
RUN apt-get -y install icinga2 icinga2-ido-mysql nagios-plugins icingaweb2 icinga2-classicui
RUN apt-get -y install nagios-nrpe-plugin --no-install-recommends

#Enable features
RUN icinga2 feature enable ido-mysql
RUN icinga2 feature enable command

#Add icinga config
RUN rm /etc/dbconfig-common/icinga2-ido-mysql.conf
ADD files/icinga/conf /etc/dbconfig-common

#Add nagios plugins
ADD files/icinga/plugins /usr/lib/nagios/plugins
RUN chmod 755 /usr/lib/nagios/plugins/check_ssl_cert

#Add Slack integration
RUN apt-get install libwww-perl libcrypt-ssleay-perl
RUN wget https://raw.github.com/tinyspeck/services-examples/master/nagios.pl
RUN mv nagios.pl /usr/local/bin/slack_nagios.pl
RUN chmod 755 /usr/local/bin/slack_nagios.pl

#Add twilio integration
RUN wget https://raw.githubusercontent.com/bfg/nagios-twilio/master/bin/twilio-sms
RUN mv twilio-sms /usr/local/bin
RUN chmod 755 /usr/local/bin/twilio-sms

#Start and stop icinga (Init system)
RUN /etc/init.d/icinga2 start && sleep 30 && /etc/init.d/icinga2 stop

#Auto redirect to icinga-web
RUN echo '<?php header("location: /icingaweb2"); ?>' > /var/www/html/index.php

#Fix timezone
RUN echo 'date.timezone = "Europe/Zurich"' >> /etc/php5/apache2/php.ini

#Edit firstboot script

#Generate setup token
RUN echo "icingacli setup config directory --group icingaweb2" >> /bin/firstboot
RUN echo 'echo "---------------------------------------------------"' >> /bin/firstboot
RUN echo "icingacli setup token create" >> /bin/firstboot
RUN echo 'echo "---------------------------------------------------"' >> /bin/firstboot

#db-config settings
RUN echo 'echo "dbc_dbuser=\"${DB_USER}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "dbc_dbpass=\"${DB_PW}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "dbc_dbserver=\"${DB_SERVER}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "dbc_dbport=\"${DB_PORT}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "dbc_dbname=\"${DB_NAME}\"" >> /etc/dbconfig-common/icinga2-ido-mysql.conf' >> /bin/firstboot

#Icinga db settings
RUN echo 'echo "library \"db_ido_mysql\"" > /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "object IdoMysqlConnection \"ido-mysql\" {" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "user = \"${DB_USER}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "password = \"${DB_PW}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "host = \"${DB_SERVER}\"," >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "port = \"${DB_PORT}\"" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "database = \"${DB_NAME}\"" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot
RUN echo 'echo "}" >> /etc/icinga2/features-available/ido-mysql.conf' >> /bin/firstboot

#Wait until database service is started (in multi container environement)
RUN echo 'sleep 30' >> /bin/firstboot
RUN echo 'mysql -u ${DB_USER} -p${DB_PW} -h ${DB_SERVER} -P ${DB_PORT} -e "CREATE DATABASE ${DB_NAME}"' >> /bin/firstboot
RUN echo 'mysql -u ${DB_USER} -p${DB_PW} -h ${DB_SERVER} -D ${DB_NAME} -P ${DB_PORT} < /usr/share/icinga2-ido-mysql/schema/mysql.sql' >> /bin/firstboot
