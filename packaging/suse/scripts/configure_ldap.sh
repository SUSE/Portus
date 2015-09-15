#!/bin/bash
cd $(dirname $0)

. check_reqs.include

check_reqs

echo "Configuring ldap support"
echo "Left blank and press enter to set up defaults"

echo "Do you want to enable ldap support?(no)"
read answer
if [ "$answer" != "yes" ];then
  echo "ldap support disabled"
  exit 0
fi

default="localhost"
echo "hostname($default)"
read ldap_hostname
if [ "$ldap_hostname" == "" ];then
  ldap_hostname=$default
fi

default=389
echo "port($default)"
read ldap_port
if [ "$ldap_port" == "" ];then
  ldap_port=$default
fi

default="ou=users, dc=example, dc=com"
echo "base($default)"
read ldap_base
if [ "$ldap_base" == "" ];then
  ldap_base=$default
fi

# enable option
sed -e "s/# SetEnv PORTUS_LDAP_ENABLED/SetEnv PORTUS_LDAP_ENABLED/g" -i $APACHE_CONF_PATH/portus.conf
# set option
sed -e "s/SetEnv PORTUS_LDAP_ENABLED.*/SetEnv PORTUS_LDAP_ENABLED true/g" -i $APACHE_CONF_PATH/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_LDAP_HOSTNAME/SetEnv PORTUS_LDAP_HOSTNAME/g" -i $APACHE_CONF_PATH/portus.conf
# set option
sed -e "s/SetEnv PORTUS_LDAP_HOSTNAME.*/SetEnv PORTUS_LDAP_HOSTNAME $ldap_hostname/g" -i $APACHE_CONF_PATH/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_LDAP_PORT/SetEnv PORTUS_LDAP_PORT/g" -i $APACHE_CONF_PATH/portus.conf
# set option
sed -e "s/SetEnv PORTUS_LDAP_PORT.*/SetEnv PORTUS_LDAP_PORT $ldap_port/g" -i $APACHE_CONF_PATH/portus.conf

# enable option
sed -e "s/# SetEnv PORTUS_LDAP_BASE/SetEnv PORTUS_LDAP_BASE/g" -i $APACHE_CONF_PATH/portus.conf
# set option
sed -e "s/SetEnv PORTUS_LDAP_BASE.*/SetEnv PORTUS_LDAP_BASE \"$ldap_base\"/g" -i $APACHE_CONF_PATH/portus.conf

