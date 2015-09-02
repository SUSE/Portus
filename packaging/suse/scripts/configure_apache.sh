#!/bin/bash

if [[ $(id -u) -ne 0 ]] ;then
  echo "Please run as root"
  exit 1
fi

echo "Configuring apache"

if [ ! -f /etc/apache2/vhosts.d/portus.conf ];then
  cp /srv/Portus/packaging/suse/conf/etc.apache2.vhosts.d.portus.conf /etc/apache2/vhosts.d/portus.conf
fi

echo "Which port do you want to run Portus on?"
read port

if [ "$port" == "" ];then
  echo "Sorry port can't be null"
  exit -1
fi

sed -e "s/<VirtualHost .*/<VirtualHost \*:$port>/g" -i /etc/apache2/vhosts.d/portus.conf

