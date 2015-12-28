# whatwedo GitLab image

include(`modules/head.m4')

# other services
include(`modules/sshd.m4')
include(`modules/nginx.m4')

# install GitLab dependencies
include(`modules/git.m4')
include(`modules/golang.m4')

# install GitLab
include(`modules/gitlab.m4')


include(`modules/cleanup.m4')

# Expose Ports
EXPOSE 22
EXPOSE 80

# Volumes
VOLUME /home/git/gitlab/tmp/backups
