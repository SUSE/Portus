#!/bin/bash

if [[ $(id -u) -ne 0 ]] ;then
  echo "Please run as root"
  exit 1
fi

if [ ! -f /etc/apache2/vhosts.d/portus.conf ];then
  cp /srv/Portus/packaging/suse/conf/etc.apache2.vhosts.d.portus.conf /etc/apache2/vhosts.d/portus.conf
fi

echo "Configuring database connection"
echo "Left blank and press enter to set up defaults"

echo "Enter username"
read db_username
echo "Enter password"
read db_password
echo "Enter host"
read db_host
echo "Enter database(portus_production)"
read db_name

if [ "$db_name" == "" ];then
  db_name="portus_production"
fi

if [ "$db_username" != "" ];then
  # enable option
  sed -e "s/# SetEnv PORTUS_PRODUCTION_USERNAME/SetEnv PORTUS_PRODUCTION_USERNAME/g" -i /etc/apache2/vhosts.d/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_USERNAME.*/SetEnv PORTUS_PRODUCTION_USERNAME $db_username/g" -i /etc/apache2/vhosts.d/portus.conf
  export PORTUS_PRODUCTION_USERNAME=$db_username
fi

if [ "$db_password" == "" ];then
  # enable option
  sed -e "s/# SetEnv PORTUS_PRODUCTION_PASSWORD/SetEnv PORTUS_PRODUCTION_PASSWORD/g" -i /etc/apache2/vhosts.d/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_PASSWORD.*/SetEnv PORTUS_PRODUCTION_PASSWORD $db_password/g" -i /etc/apache2/vhosts.d/portus.conf
  export PORTUS_PRODUCTION_PASSWORD=$db_password
fi

if [ "$db_host" == "" ];then
  # enable option
  sed -e "s/# SetEnv PORTUS_PRODUCTION_HOST/SetEnv PORTUS_PRODUCTION_HOST/g" -i /etc/apache2/vhosts.d/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_HOST.*/SetEnv PORTUS_PRODUCTION_HOST $db_host/g" -i /etc/apache2/vhosts.d/portus.conf
  export PORTUS_PRODUCTION_HOST=$db_host
fi

# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_DATABASE/SetEnv PORTUS_PRODUCTION_HOST/g" -i /etc/apache2/vhosts.d/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_DATABASE.*/SetEnv PORTUS_PRODUCTION_HOST $db_name/g" -i /etc/apache2/vhosts.d/portus.conf
export PORTUS_PRODUCTION_DATABASE=$db_name

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
echo "Set pasword"
PORTUS_PASSWORD=$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))$(($RANDOM%10))
sed -e "s/SetEnv PORTUS_PASSWORD.*/SetEnv PORTUS_PASSWORD $PORTUS_PASSWORD/g" -i /etc/apache2/vhosts.d/portus.conf
export PORTUS_PASSWORD
$bundle exec rake db:seed
popd
