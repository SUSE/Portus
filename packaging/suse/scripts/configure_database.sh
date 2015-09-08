#!/bin/bash
cd $(dirname $0)

. check_reqs.include

check_reqs

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
  sed -e "s/# SetEnv PORTUS_PRODUCTION_USERNAME/SetEnv PORTUS_PRODUCTION_USERNAME/g" -i $APACHE_CONF_PATH/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_USERNAME.*/SetEnv PORTUS_PRODUCTION_USERNAME $db_username/g" -i $APACHE_CONF_PATH/portus.conf
fi

if [ "$db_password" != "" ];then
  # enable option
  sed -e "s/# SetEnv PORTUS_PRODUCTION_PASSWORD/SetEnv PORTUS_PRODUCTION_PASSWORD/g" -i $APACHE_CONF_PATH/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_PASSWORD.*/SetEnv PORTUS_PRODUCTION_PASSWORD $db_password/g" -i $APACHE_CONF_PATH/portus.conf
fi

if [ "$db_host" != "" ];then
  # enable option
  sed -e "s/# SetEnv PORTUS_PRODUCTION_HOST/SetEnv PORTUS_PRODUCTION_HOST/g" -i $APACHE_CONF_PATH/portus.conf
  # set option
  sed -e "s/SetEnv PORTUS_PRODUCTION_HOST.*/SetEnv PORTUS_PRODUCTION_HOST $db_host/g" -i $APACHE_CONF_PATH/portus.conf
fi

# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_DATABASE/SetEnv PORTUS_PRODUCTION_HOST/g" -i $APACHE_CONF_PATH/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_DATABASE.*/SetEnv PORTUS_PRODUCTION_HOST $db_name/g" -i $APACHE_CONF_PATH/portus.conf


