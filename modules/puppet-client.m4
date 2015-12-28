
# Install Puppet Client
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update
RUN apt-get install puppet=3.8.4-1puppetlabs1 -qq < "/dev/null" 
RUN rm puppetlabs-release-trusty.deb