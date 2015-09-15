#!/bin/bash

cd $(dirname $0)

. check_reqs.include

check_reqs

bundle="/srv/Portus/vendor/bundle/ruby/2.1.0/bin/bundler.ruby2.1"
export GEM_PATH=/srv/Portus/vendor/bundle/ruby/2.1.0/
pushd /srv/Portus

export SKIP_MIGRATION=yes
export RAILS_ENV=production


echo "Create database"
$bundle exec rake db:create
echo "Run migrations"
$bundle exec rake db:migrate

echo "Seed"

# Set password for portus user
echo "Set password for user portus"
PORTUS_PASSWORD=$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))
sed -e "s/SetEnv PORTUS_PASSWORD.*/SetEnv PORTUS_PASSWORD $PORTUS_PASSWORD/g" -i $APACHE_CONF_PATH/portus.conf
export PORTUS_PASSWORD
$bundle exec rake db:seed
popd
