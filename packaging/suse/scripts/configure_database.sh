#!/bin/bash

if [ ! -f /etc/apache2/vhosts.d/portus.conf ];then
  cp /srv/Portus/packaging/suse/conf/etc.apache2.vhosts.d.portus.conf /etc/apache2/vhosts.d/portus.conf
fi

echo "Configuring database connection"

echo "Enter username"
read db_username
echo "Enter password"
read db_password
echo "Enter host"
read db_host
echo "Enter database"
read db_name
# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_USERNAME/SetEnv PORTUS_PRODUCTION_USERNAME/g" -i /etc/apache2/vhosts.d/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_USERNAME.*/SetEnv PORTUS_PRODUCTION_USERNAME $db_username/g" -i /etc/apache2/vhosts.d/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_PASSWORD/SetEnv PORTUS_PRODUCTION_PASSWORD/g" -i /etc/apache2/vhosts.d/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_PASSWORD.*/SetEnv PORTUS_PRODUCTION_PASSWORD $db_password/g" -i /etc/apache2/vhosts.d/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_HOST/SetEnv PORTUS_PRODUCTION_HOST/g" -i /etc/apache2/vhosts.d/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_HOST.*/SetEnv PORTUS_PRODUCTION_HOST $db_host/g" -i /etc/apache2/vhosts.d/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_PRODUCTION_DATABASE/SetEnv PORTUS_PRODUCTION_HOST/g" -i /etc/apache2/vhosts.d/portus.conf
# set option
sed -e "s/SetEnv PORTUS_PRODUCTION_DATABASE.*/SetEnv PORTUS_PRODUCTION_HOST $db_name/g" -i /etc/apache2/vhosts.d/portus.conf


