#!/bin/bash

echo "Configuring registry ..."
HOSTNAME=$(cat /etc/HOSTNAME)
sed -e "s/__HOSTNAME__/$HOSTNAME/g" /srv/Portus/packaging/suse/conf/registry/config.yml.in > /etc/registry/config.yml

