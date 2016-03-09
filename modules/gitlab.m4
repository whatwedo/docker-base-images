# Install GitLab from package sources
LASTRUN apt-get update && apt-get install -y \
    build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev \
    libreadline-dev libncurses5-dev libffi-dev curl openssh-server \
    checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
    logrotate python-docutils pkg-config cmake nodejs libmysqlclient-dev \
    mysql-client redis-tools nginx-extras

# Install Ruby 2.1
RUN mkdir /tmp/ruby
RUN cd /tmp/ruby && curl -O --progress https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.8.tar.gz
RUN cd /tmp/ruby && echo 'c7e50159357afd87b13dc5eaf4ac486a70011149  ruby-2.1.8.tar.gz' | shasum -c - && tar xzf ruby-2.1.8.tar.gz
RUN cd /tmp/ruby && cd ruby-2.1.8 && ./configure --disable-install-rdoc && make && make install
LASTRUN gem install bundler --no-ri --no-rdoc

# GitLab
RUN adduser --disabled-login --gecos 'GitLab' git
RUN sudo -u git -H mkdir -p /home/git/.ssh
RUN sudo -u git -H touch /home/git/.ssh/authorized_keys
RUN sudo -u git -H git config --global core.autocrlf "input"
RUN sudo -u git -H curl -L https://github.com/gitlabhq/gitlabhq/archive/v8.5.4.zip -o /home/git/gitlab.zip
RUN sudo -u git -H unzip /home/git/gitlab.zip -d /home/git
RUN sudo -u git -H mv /home/git/gitlabhq-* /home/git/gitlab
RUN sudo -u git -H rm /home/git/gitlab.zip
ADD files/gitlab/gitlab.yml /home/git/gitlab/config/
RUN chown git /home/git/gitlab/config/
RUN sudo -u git -H cp /home/git/gitlab/config/secrets.yml.example /home/git/gitlab/config/secrets.yml
RUN sudo -u git -H chmod 0600 /home/git/gitlab/config/secrets.yml
RUN chown -R git /home/git/gitlab/log/
RUN chown -R git /home/git/gitlab/tmp/
RUN chmod -R u+rwX,go-w /home/git/gitlab/log/
RUN chmod -R u+rwX /home/git/gitlab/tmp/
RUN sudo -u git -H mkdir -p /home/git/gitlab/tmp/pid
RUN sudo -u git -H mkdir -p /home/git/gitlab/tmp/sockets
RUN sudo -u git -H mkdir -p /home/git/gitlab/tmp/backups
RUN sudo -u git -H mkdir -p /home/git/gitlab/tmp/sessions
RUN chmod -R u+rwX /home/git/gitlab/tmp/pids/
RUN chmod -R u+rwX /home/git/gitlab/tmp/sockets/
RUN chmod -R u+rwX /home/git/gitlab/tmp/backups/
RUN chmod -R u+rwX /home/git/gitlab/tmp/sessions/
RUN chmod -R u+rwX /home/git/gitlab/builds/
RUN chmod -R u+rwX /home/git/gitlab/shared/artifacts/
RUN sudo -u git -H cp /home/git/gitlab/config/unicorn.rb.example /home/git/gitlab/config/unicorn.rb
RUN sudo -u git -H cp /home/git/gitlab/config/initializers/rack_attack.rb.example /home/git/gitlab/config/initializers/rack_attack.rb
RUN sudo -u git -H cp /home/git/gitlab/config/resque.yml.example /home/git/gitlab/config/resque.yml
RUN sudo -u git -H cp /home/git/gitlab/config/database.yml.mysql /home/git/gitlab/config/database.yml
RUN sudo -u git -H chmod o-rwx /home/git/gitlab/config/database.yml
LASTRUN cd /home/git/gitlab && sudo -u git -H bundle install --deployment --without development test postgres aws kerberos

# nginx
RUN rm /etc/nginx/nginx.conf
COPY files/gitlab/nginx.conf /etc/nginx/nginx.conf

# GitLab Workhorse
RUN sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git /home/git/gitlab-workhorse
RUN cd /home/git/gitlab-workhorse && sudo -u git -H git checkout 0.6.5
LASTRUN cd /home/git/gitlab-workhorse && sudo -u git -H PATH=$PATH:/usr/local/go/bin:/go/bin ; make

# firstboot
RUN echo 'echo "checking data directories"' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/artifacts' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/lfs/lfs-objects' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/ci/builds/' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/shared' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/gitlab-satellites' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/backups' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/repositories' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/gitlab-shell/hooks' >> /bin/everyboot
RUN echo 'sudo mkdir -p /data/public/uploads' >> /bin/everyboot
RUN echo 'chown -R git:git /data' >> /bin/everyboot
RUN sudo -u git -H mkdir -p /home/git/.ssh
RUN echo 'chown -R git:git /home/git/.ssh' >> /bin/everyboot
RUN sudo -u git -H touch /home/git/.ssh/authorized_keys

RUN echo 'echo "symlink uploads directory"' >> /bin/everyboot
RUN echo 'rm -rf /home/git/gitlab/public/uploads' >> /bin/everyboot
RUN echo 'sudo -u git -H ln -sf /data/public/uploads /home/git/gitlab/public/uploads' >> /bin/everyboot

RUN echo 'cd /home/git/gitlab' >> /bin/everyboot
RUN echo 'echo "configuring GitLab"' >> /bin/everyboot
RUN echo 'sed -i s/^worker_processes.*/worker_processes\ ${UNICORN_WORKER_PROCESSES}/g config/unicorn.rb' >> /bin/everyboot

RUN echo 'sed -i s/{{GITLAB_HOST}}/${GITLAB_HOST}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PORT}}/${GITLAB_PORT}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_HTTPS}}/${GITLAB_HTTPS}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_EMAIL_FROM}}/${GITLAB_EMAIL_FROM}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_EMAIL_DISPLAY_NAME}}/${GITLAB_EMAIL_DISPLAY_NAME}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_EMAIL_REPLY_TO}}/${GITLAB_EMAIL_REPLY_TO}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_DEFAULT_THEME}}/${GITLAB_DEFAULT_THEME}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_ISSUES}}/${GITLAB_PROJECT_FEATURES_ISSUES}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_MERGE_REQUEST}}/${GITLAB_PROJECT_FEATURES_MERGE_REQUEST}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_WIKI}}/${GITLAB_PROJECT_FEATURES_WIKI}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_SNIPPETS}}/${GITLAB_PROJECT_FEATURES_SNIPPETS}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_BUILDS}}/${GITLAB_PROJECT_FEATURES_BUILDS}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_BACKUP_KEEP_TIME}}/${GITLAB_BACKUP_KEEP_TIME}/g config/gitlab.yml' >> /bin/everyboot

RUN echo 'sed -i s/#\ db_key_base\:$/db_key_base:\ ${GITLAB_DATABASE_SECRET_KEY}/g config/secrets.yml' >> /bin/everyboot
RUN echo 'sed -i s@production\:.*@production\:\ ${REDIS_URL}@g config/resque.yml' >> /bin/everyboot
RUN echo 'sed -i s/username\:.*/username\:\ ${DATABASE_USER}/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/password\:.*/password\:\ "${DATABASE_PASSWORD}"/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/database\:.*/database\:\ ${DATABASE_NAME}/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/#\ host\:.*/host\:\ ${DATABASE_HOST}/g config/database.yml' >> /bin/everyboot

RUN echo 'cp config/initializers/smtp_settings.rb.sample config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/address\:.*/address\:\ \"${GITLAB_EMAIL_SMTP_ADDRESS}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/user_name\:.*/user_name\:\ \"${GITLAB_EMAIL_SMTP_USERNAME}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/password\:.*/password\:\ \"${GITLAB_EMAIL_SMTP_PASSWORD}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/domain\:.*/domain\:\ \"${GITLAB_EMAIL_SMTP_DOMAIN}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot

RUN echo 'echo "Wait for MySQL to boot..."' >> /bin/everyboot
RUN echo 'echo "while ! nc -z ${DATABASE_HOST} 3306; do sleep 3; done"' >> /bin/everyboot

RUN echo 'echo "Installing GitLab Shell"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake gitlab:shell:install REDIS_URL=${REDIS_URL} RAILS_ENV=production' >> /bin/everyboot
RUN echo 'sed -i s@gitlab_url\:.*@gitlab_url\:\ http\://127.0.0.1\:8080@g /home/git/gitlab-shell/config.yml' >> /bin/everyboot

# START GitLab initial installation

RUN echo 'if [ ! -f /etc/firstboot/gitlab-flag ];' >> /bin/everyboot
RUN echo 'then' >> /bin/everyboot

RUN echo '  echo "Creating SSH Keys"' >> /bin/everyboot
RUN echo '  echo -e "y\n"|sudo -u git -H ssh-keygen -q -t rsa -N "" -f /home/git/.ssh/id_rsa' >> /bin/everyboot

RUN echo '  echo "Installing GitLab"' >> /bin/everyboot
RUN echo '  sudo -u git -H force=yes bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=${GITLAB_ROOT_PASSWORD}' >> /bin/everyboot

RUN echo '  echo "Installing Backup CronJob"' >> /bin/everyboot
RUN echo '  sudo -u git -H crontab -l > /home/git/gitlab/tmp/cron' >> /bin/everyboot
RUN echo '  echo "${GITLAB_BACKUP_CRON} cd /home/git/gitlab && bundle exec rake gitlab:backup:create RAILS_ENV=production" >> /home/git/gitlab/tmp/cron' >> /bin/everyboot
RUN echo '  sudo -u git -H crontab /home/git/gitlab/tmp/cron' >> /bin/everyboot
RUN echo '  sudo -u git -H rm /home/git/gitlab/tmp/cron' >> /bin/everyboot
RUN echo '  date > /etc/firstboot/gitlab-flag' >> /bin/everyboot
RUN echo 'chmod 600 /home/git/.ssh/id_rsa' >> /bin/everyboot
RUN echo 'chmod 644 /home/git/.ssh/id_rsa.pub' >> /bin/everyboot

RUN echo '  echo ""' >> /bin/everyboot
RUN echo '  echo "#########################"' >> /bin/everyboot
RUN echo '  echo "# GitLab Setup finished #"' >> /bin/everyboot
RUN echo '  echo "#########################"' >> /bin/everyboot
RUN echo '  echo ""' >> /bin/everyboot

RUN echo 'fi' >> /bin/everyboot

# END GitLab Initial Installation

RUN echo 'echo "Migrate database"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production' >> /bin/everyboot

RUN echo 'echo "Precompiling assets"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production' >> /bin/everyboot

RUN echo 'echo "Rebuild authorized_keys file"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake gitlab:shell:setup RAILS_ENV=production force=yes' >> /bin/everyboot

RUN echo 'touch /home/git/gitlab/log/gitlab-workhorse.log' >> /bin/everyboot
RUN echo 'touch /home/git/gitlab/log/mail_room.log' >> /bin/everyboot
RUN echo 'touch /home/git/gitlab/log/production.log' >> /bin/everyboot
RUN echo 'touch /home/git/gitlab/log/sidekiq.log' >> /bin/everyboot
RUN echo 'touch /home/git/gitlab/log/unicorn.stderr.log' >> /bin/everyboot
RUN echo 'touch /home/git/gitlab/log/unicorn.stdout.log' >> /bin/everyboot
RUN echo 'chown -R git:git /home/git/gitlab/log' >> /bin/everyboot

RUN echo 'echo ""' >> /bin/everyboot
RUN echo 'echo "######################"' >> /bin/everyboot
RUN echo 'echo "# GitLab initialized #"' >> /bin/everyboot
RUN echo 'echo "######################"' >> /bin/everyboot
LASTRUN echo 'echo ""' >> /bin/everyboot

# Add GitLab to supervisord config
COPY files/supervisord/gitlab.conf /etc/supervisor/conf.d/gitlab.conf
