FROM ubuntu:14.04

#Maintainer
MAINTAINER whatwedo GmbH <welove@whatwedo.ch>

#Base settings
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

#Prevent initramfs updates from trying to run grub and lilo.
#https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
#http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
RUN export INITRD=no
RUN mkdir -p /etc/container_environment
RUN echo -n no > /etc/container_environment/INITRD

#Enable Ubuntu Universe and Multiverse.
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list

#Update system
RUN apt-get update -y
RUN apt-get upgrade -y

#Install HTTPS support for APT
RUN apt-get install -y apt-transport-https ca-certificates software-properties-common

#Fix locales
RUN apt-get install -y language-pack-en
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
RUN echo -n en_US.UTF-8 > /etc/container_environment/LANG
RUN echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE
ENV LANG en_US.UTF-8
RUN apt-get install localepurge

#Fix: TERM environment variable not set.
ENV TERM dumb

#Add upstart script
ADD files/upstart /bin
RUN chmod 755 /bin/upstart
CMD /bin/upstart

#Add firstbootscript
ADD files/firstboot /bin
RUN chmod 755 /bin/firstboot
VOLUME  ["/etc/firstboot"]

#Set motd
ADD files/motd /etc

#Install often used tools
RUN apt-get install -y curl less nano wget zip unzip supervisor rsyslog python-pip
RUN pip install supervisor-stdout

#Add default supervisord config
COPY files/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/supervisord/cron.conf /etc/supervisor/conf.d/cron.conf
COPY files/supervisord/syslog.conf /etc/supervisor/conf.d/syslog.conf

#Touch redirected logfiles
RUN touch /var/log/syslog && chown syslog:adm /var/log/syslog
RUN touch /var/log/cron.log && chown syslog:adm /var/log/cron.log

#Remove useless crone entries
RUN rm -f /etc/cron.daily/standard
RUN rm -f /etc/cron.daily/upstart
RUN rm -f /etc/cron.daily/dpkg
RUN rm -f /etc/cron.daily/password
RUN rm -f /etc/cron.weekly/fstrim

#Taken from here: https://gist.github.com/kwk/55bb5b6a4b7457bef38d
#this forces dpkg not to call sync() after package extraction and speeds up
#install
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
#we don't need and apt cache in a container
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache



