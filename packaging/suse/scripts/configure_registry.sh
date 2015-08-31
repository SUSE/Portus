#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "Configuring registry ..."
HOSTNAME=$(cat /etc/HOSTNAME)
sed -e "s/__HOSTNAME__/$HOSTNAME/g" /srv/Portus/packaging/suse/conf/registry/config.yml.in > /etc/registry/config.yml

