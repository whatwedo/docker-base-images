#whatwedo Tomcat image

include(`modules/head.m4')
include(`modules/java.m4')
include(`modules/maven.m4')
include(`modules/tomcat.m4')
include(`modules/cleanup.m4')

#Alter upstart script
RUN echo -n "/opt/tomcat/bin/catalina.sh run" >> /bin/upstart

#Expose Ports
EXPOSE 8080