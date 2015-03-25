#Install postgres
RUN apt-get install -y postgresql postgresql-client

# Run the following of the commands as postgres
USER postgres

#Allow connections from everywhere
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

psql -c "alter user postgres password '';"

# Run the following of the commands as root
USER root