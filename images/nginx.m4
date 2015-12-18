#whatwedo nginx image

include(`modules/head.m4')
include(`modules/nginx.m4')
include(`modules/cleanup.m4')

#Expose Ports
EXPOSE 80
EXPOSE 443
