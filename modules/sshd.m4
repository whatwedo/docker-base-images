# Install SSH
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# Disabling use DNS in ssh
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# Add SSH to supervisord config
COPY files/supervisord/sshd.conf /etc/supervisor/conf.d/sshd.conf
