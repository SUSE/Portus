#!/bin/bash
cd $(dirname $0)

. check_reqs.include

check_reqs

echo "Which port do you want to run Portus on?"
read port

if [ "$port" == "" ];then
  echo "Sorry port can't be null"
  exit -1
fi

sed -e "s/<VirtualHost .*/<VirtualHost \*:$port>/g" -i $APACHE_CONF_PATH/portus.conf
sed -e "s/SetEnv PORTUS_MACHINE_FQDN.*/SetEnv PORTUS_MACHINE_FQDN $HOSTNAME/g" -i $APACHE_CONF_PATH/portus.conf

