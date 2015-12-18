#whatwedo PostgreSQL image

include(`modules/head.m4')
include(`modules/postgres.m4')
include(`modules/cleanup.m4')

#Create volumes
VOLUME  ["/var/lib/postgresql"]

#Expose Ports
EXPOSE 5432