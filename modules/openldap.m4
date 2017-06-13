# Install openldap
RUN apt install -qq slapd ldap-utils

# Edit firstboot
RUN echo 'SLAPD_ORGANIZATION="${SLAPD_ORGANIZATION:-${SLAPD_DOMAIN}}"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/no_configuration boolean false"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/password1 password $SLAPD_PASSWORD"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/password2 password $SLAPD_PASSWORD"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd shared/organization string $SLAPD_ORGANIZATION"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/domain string $SLAPD_DOMAIN"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/backend select HDB"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/allow_ldap_v2 boolean false"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/purge_database boolean false"' >> /bin/firstboot
RUN echo 'debconf-set-selections <<< "slapd slapd/move_old_database boolean true"' >> /bin/firstboot
RUN echo 'dpkg-reconfigure -f noninteractive slapd' >> /bin/firstboot

# Edit everyboot
RUN echo 'ulimit -n 1024' >> /bin/everyboot # When not limiting the open file descritors limit, the memory consumption of slapd is absurdly high

#Add openldap to supervisord config
COPY files/supervisord/openldap.conf /etc/supervisor/conf.d/openldap.conf
