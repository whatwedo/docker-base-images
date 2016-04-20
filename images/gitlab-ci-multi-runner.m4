# whatwedo GitLab Runner

include(`modules/head.m4')

# install GitLab
include(`modules/gitlab-ci-multi-runner.m4')

include(`modules/cleanup.m4')

# Volumes
VOLUME /etc/gitlab-runner
