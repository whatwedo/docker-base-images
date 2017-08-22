# Install GitLab from package sources

LASTRUN add-apt-repository ppa:pi-rho/security -y
RUN apt-get update 
RUN apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev \
                       libreadline-dev libncurses5-dev libffi-dev curl openssh-server \
                       checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
                       logrotate python-docutils pkg-config cmake libmysqlclient-dev \
                       mysql-client redis-tools libre2-0 libre2-0-dev

# Install Ruby 2.3
RUN mkdir /tmp/ruby
RUN cd /tmp/ruby
RUN curl -L https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.4.tar.gz -o ruby.tar.gz
RUN echo 'd064b9c69329ca2eb2956ad57b7192184178e35d  ruby.tar.gz' | shasum -c - && tar xzf ruby.tar.gz
RUN ls -alh && cd ruby-* && ./configure --disable-install-rdoc && make && make install
LASTRUN gem install bundler --no-ri --no-rdoc

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarnpkg.list
LASTRUN apt-get update && sudo apt-get install yarn -y

# GitLab
RUN adduser --disabled-login --gecos 'GitLab' git
RUN sudo -u git -H mkdir -p /home/git/.ssh
RUN sudo -u git -H touch /home/git/.ssh/authorized_keys
RUN sudo -u git -H git config --global core.autocrlf "input"
RUN sudo -u git -H git config --global gc.auto 0
RUN sudo -u git -H git config --global repack.writeBitmaps true
RUN sudo -u git -H curl -L https://gitlab.com/gitlab-org/gitlab-ce/repository/v9.4.5/archive.zip -o /home/git/gitlab.zip
RUN sudo -u git -H echo '1c8fec9e40a479c365b253fe554668b495d8eb2d  /home/git/gitlab.zip' | shasum -c -
RUN sudo -u git -H unzip /home/git/gitlab.zip -d /home/git
RUN sudo -u git -H mv /home/git/gitlab-ce-* /home/git/gitlab
RUN sudo -u git -H rm /home/git/gitlab.zip
ADD files/gitlab/gitlab.yml /home/git/gitlab/config/
ADD files/gitlab/secrets.yml /home/git/gitlab/config/
RUN chown git:git /home/git/gitlab/config/
RUN chown git:git /home/git/gitlab/config/*
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
RUN sed s/127.0.0.1:8080/127.0.0.1:80/g /home/git/gitlab/config/unicorn.rb
RUN sudo -u git -H cp /home/git/gitlab/config/initializers/rack_attack.rb.example /home/git/gitlab/config/initializers/rack_attack.rb
RUN sudo -u git -H cp /home/git/gitlab/config/resque.yml.example /home/git/gitlab/config/resque.yml
RUN sudo -u git -H cp /home/git/gitlab/config/database.yml.mysql /home/git/gitlab/config/database.yml
RUN sudo -u git -H chmod o-rwx /home/git/gitlab/config/database.yml
RUN echo 'PATH="/home/git/gitlab-workhorse:$PATH"' >> /home/git/.profile
LASTRUN cd /home/git/gitlab && sudo -u git -H bundle install --deployment --without development test postgres aws kerberos && sudo -u git -H npm install

# nginx
RUN rm /etc/nginx/nginx.conf
COPY files/gitlab/nginx.conf /etc/nginx/nginx.conf

# GitLab Workhorse
RUN sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git /home/git/gitlab-workhorse
RUN cd /home/git/gitlab-workhorse && sudo -u git -H git checkout v$(cat /home/git/gitlab/GITLAB_WORKHORSE_VERSION)
RUN cd /home/git/gitlab-workhorse && PATH=$PATH:/usr/local/go/bin:/go/bin make && chown -R git:git /home/git/gitlab-workhorse
RUN ln -s /home/git/gitlab-workhorse/gitlab-zip-cat /usr/local/bin/gitlab-zip-cat
LASTRUN ln -s /home/git/gitlab-workhorse/gitlab-zip-metadata /usr/local/bin/gitlab-zip-metadata

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
RUN echo 'sed -i s/{{GITLAB_PROJECT_FEATURES_CONTAINER_REGISTRY}}/${GITLAB_PROJECT_FEATURES_CONTAINER_REGISTRY}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_BACKUP_KEEP_TIME}}/${GITLAB_BACKUP_KEEP_TIME}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_ENABLED}}/${GITLAB_INCOMING_EMAIL_ENABLED}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_ADDRESS}}/${GITLAB_INCOMING_EMAIL_ADDRESS}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_USER}}/${GITLAB_INCOMING_EMAIL_USER}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_PASSWORD}}/${GITLAB_INCOMING_EMAIL_PASSWORD}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_IMAP_HOST}}/${GITLAB_INCOMING_EMAIL_IMAP_HOST}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_IMAP_PORT}}/${GITLAB_INCOMING_EMAIL_IMAP_PORT}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_IMAP_SSL}}/${GITLAB_INCOMING_EMAIL_IMAP_SSL}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_IMAP_STARTTLS}}/${GITLAB_INCOMING_EMAIL_IMAP_STARTTLS}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{GITLAB_INCOMING_EMAIL_IMAP_MAILBOX}}/${GITLAB_INCOMING_EMAIL_IMAP_MAILBOX}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{CONTAINER_REGISTRY_HOST}}/${CONTAINER_REGISTRY_HOST}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{CONTAINER_REGISTRY_PORT}}/${CONTAINER_REGISTRY_PORT}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s@{{CONTAINER_REGISTRY_API_URL}}@${CONTAINER_REGISTRY_API_URL}@g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{CONTAINER_REGISTRY_ISSUER}}/${CONTAINER_REGISTRY_ISSUER}/g config/gitlab.yml' >> /bin/everyboot
RUN echo 'sed -i s/{{CONTAINER_TIMEZONE}}/${CONTAINER_TIMEZONE}/g config/gitlab.yml' >> /bin/everyboot

RUN echo 'sed -i s/db_key_base\:.*$/db_key_base:\ ${GITLAB_DATABASE_SECRET_KEY}/g config/secrets.yml' >> /bin/everyboot
RUN echo 'sed -i s/secret_key_base\:.*$/secret_key_base:\ ${GITLAB_SECRET_KEY_BASE}/g config/secrets.yml' >> /bin/everyboot
RUN echo 'sed -i s/otp_key_base\:.*$/otp_key_base:\ ${GITLAB_DATABASE_OTP_KEY_BASE}/g config/secrets.yml' >> /bin/everyboot
RUN echo 'sed -i s@url\:.*@url\:\ ${REDIS_URL}@g config/resque.yml' >> /bin/everyboot
RUN echo 'sed -i s/username\:.*/username\:\ ${DATABASE_USER}/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/password\:.*/password\:\ "${DATABASE_PASSWORD}"/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/database\:.*/database\:\ ${DATABASE_NAME}/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/#\ host\:.*/host\:\ ${DATABASE_HOST}/g config/database.yml' >> /bin/everyboot
RUN echo 'sed -i s/config.action_mailer.delivery_method\ =\ :sendmail/config.action_mailer.delivery_method\ =\ :smtp/g config/environments/production.rb' >> /bin/everyboot

RUN echo 'cp config/initializers/smtp_settings.rb.sample config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/address\:.*/address\:\ \"${GITLAB_EMAIL_SMTP_ADDRESS}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/port\:.*/port\:\ ${GITLAB_EMAIL_SMTP_PORT},/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/authentication\:.*/authentication\:\ \:${GITLAB_EMAIL_SMTP_AUTHENTICATION},/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/user_name\:.*/user_name\:\ \"${GITLAB_EMAIL_SMTP_USERNAME}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/password\:.*/password\:\ \"${GITLAB_EMAIL_SMTP_PASSWORD}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/domain\:.*/domain\:\ \"${GITLAB_EMAIL_SMTP_DOMAIN}\",/g config/initializers/smtp_settings.rb' >> /bin/everyboot
RUN echo 'sed -i s/openssl_verify_mode\:.*/openssl_verify_mode\:\ \"${GITLAB_EMAIL_SMTP_VERIFY_MODE}\",\\\\n\ \ \ \ tls:\ true,/g config/initializers/smtp_settings.rb' >> /bin/everyboot

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

RUN echo 'echo "Precompiling assets in the background"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake yarn:install RAILS_ENV=production NODE_ENV=production' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake gitlab:assets:clean RAILS_ENV=production NODE_ENV=production' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production' >> /bin/everyboot

RUN echo 'echo "Rebuild authorized_keys file"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake gitlab:shell:setup RAILS_ENV=production force=yes' >> /bin/everyboot

RUN echo 'echo "Clear cache"' >> /bin/everyboot
RUN echo 'sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production' >> /bin/everyboot

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
