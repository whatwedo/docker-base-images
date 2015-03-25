#!/bin/bash
##################################################################
#                                                                #
# @Version:				0.1                                      #
# @Author:				Felix Imobersteg  			  			 #
# Description:                                                   #
# This script install required VM dependecies                    #
#													             #
##################################################################

#Change directory
cd /tmp

#Update sytem
apt-get update -y
apt-get upgrade -y

#Install base packages
apt-get install nano vim less zip unzip telnet git curl -y

#Install docker
curl -sSL https://get.docker.com/ubuntu/ | sh

#Enable aufs
apt-get -y install linux-image-extra-$(uname -r) aufs-tools
apt-get -y install lxc-docker
service docker restart

#Use docker with vagrant user without sudo
gpasswd -a vagrant docker
service docker restart

#Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#Install archey
apt-get install scrot lsb-release -y
wget https://github.com/downloads/djmelik/archey/archey-0.2.8.deb
dpkg -i archey-0.2.8.deb
echo "archey" >> /etc/bash.bashrc

#Install m4
apt-get install -y m4

#Set logonscreen
rm /etc/motd.tail
cp /vagrant/vm-init/files/motd/* /etc
apt-get remove --purge landscape-common -y
rm -rf /etc/update-motd.d/*
apt-get remove update-notifier-common update-manager-core

#Cleanup
apt-get autoremove -y
apt-get autoclean -y

