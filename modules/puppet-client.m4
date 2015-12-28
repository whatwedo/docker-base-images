
# Install Puppet Client
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg -i puppetlabs-release-trusty.deb
apt-get update
apt-get install puppet=3.8.4-1puppetlabs1 -qq < "/dev/null" # not that nice but prevents from exiting other than 0
rm puppetlabs-release-trusty.deb