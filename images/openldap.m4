# whatwedo openLDAP image

include(`modules/head.m4')
include(`modules/openldap.m4')

# Expose default ldap and ldaps ports
EXPOSE 389

# Create volumes
VOLUME  ["/var/lib/ldap", "/etc/ldap/slapd.d"]
