#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "Configuring registry ..."
echo "Do you want to configure the local registry with portus?"
echo "If you answer 'yes', the local registry configuration will be overwritten"
read answer
if [ "$answer" != "yes" ];then
  exit
fi

HOSTNAME=$(cat /etc/HOSTNAME)
echo "Create backup at /etc/registry/config.yml.portus.back"
cp /etc/registry/config.yml /etc/registry/config.yml.portus.back
sed -e "s/__HOSTNAME__/$HOSTNAME/g" /srv/Portus/packaging/suse/conf/registry/config.yml.in > /etc/registry/config.yml

