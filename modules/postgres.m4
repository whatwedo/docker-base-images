#Install postgres
RUN apt-get install -y postgresql postgresql-client

# Run the following of the commands as postgres
USER postgres

#Allow connections from everywhere
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf


# Run the following of the commands as root
USER root

#Edit firstboot script
RUN echo "/etc/init.d/postgresql start" >> /bin/firstboot
RUN echo 'echo "alter user postgres password \0047${PG_ROOT_PASSWORD}\0047;" > /pg-first-time.sql' >> /bin/firstboot
RUN echo 'su postgres -c "psql -f /pg-first-time.sql"' >> /bin/firstboot
RUN echo 'rm /pg-first-time.sql' >> /bin/firstboot
RUN echo "/etc/init.d/postgresql stop" >> /bin/firstboot

#Add postgres to supervisord config
COPY files/supervisord/postgres.conf /etc/supervisor/conf.d/postgres.conf

#Fix permission bug: https://github.com/hw-cookbooks/postgresql/issues/156
RUN chown postgres /etc/ssl/private/ssl-cert-snakeoil.key
RUN sudo chown postgres /etc/ssl/certs/ssl-cert-snakeoil.pem