#Install MongoDB Repo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
RUN add-apt-repository 'deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse'

#Install Mongo DB
RUN apt-get update 
RUN apt-get install -y mongodb-org

#Create data directory
RUN mkdir -p /data/db