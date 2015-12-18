#whatwedo Tomcat image

include(`modules/head.m4')
include(`modules/java.m4')
include(`modules/maven.m4')
include(`modules/tomcat.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 8080