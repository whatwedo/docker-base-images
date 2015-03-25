#whatwedo PostgreSQL image

include(`modules/head.m4')
include(`modules/postgres.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n '/bin/su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf"' >> /bin/upstart

#Create volumes
VOLUME  ["/var/lib/postgresql"]

#Expose Ports
EXPOSE 5432