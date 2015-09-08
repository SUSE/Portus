#!/bin/bash
cd $(dirname $0)

if [[ $(id -u) -ne 0 ]] ;then
  echo "Please run as root"
  exit 1
fi

echo "Configuring ssl ..."

HOSTNAME=$(cat /etc/HOSTNAME)

if [ ! -f /etc/apache2/ssl.key/$HOSTNAME-server.key ];then
  echo "Generating private key and certificate"
  echo ""
  echo "***********************************************************************************************************************************"
  echo "If you want to use your own private key and certificates, upload them to"
  echo "  * /etc/apache2/ssl.key/$HOSTNAME-server.key"
  echo "  * /etc/apache2/ssl.crt/$HOSTNAME-server.crt"
  echo "  * /etc/apache2/ssl.crt/$HOSTNAME-ca.crt"
  echo "and then re-run this script"
  echo "***********************************************************************************************************************************"
  echo ""
  gensslcert -C "$HOSTNAME" -o "SUSE Linux GmbH" -u "SUSE Portus example" -n "$HOSTNAME" -e kontakt-de@novell.com -c DE -l Nuremberg -s Bayern
fi

if [ ! -d /etc/registry/ssl.crt ];then
  mkdir -p /etc/registry/ssl.crt
fi

chgrp www /etc/apache2/ssl.key/$HOSTNAME-server.key
chmod 440 /etc/apache2/ssl.key/$HOSTNAME-server.key 
cd /srv/Portus/config
ln -sf //etc/apache2/ssl.key/$HOSTNAME-server.key server.key
chgrp www /etc/apache2/ssl.key
chmod 750 /etc/apache2/ssl.key/
cd /etc/registry/ssl.crt/
ln -sf /etc/apache2/ssl.crt/$HOSTNAME-server.crt portus.crt
cp /etc/apache2/ssl.crt/$HOSTNAME-ca.crt /srv/www/htdocs/
cp /etc/apache2/ssl.crt/$HOSTNAME-ca.crt /etc/pki/trust/anchors/
update-ca-certificates
chmod 755 /srv/www/htdocs/$HOSTNAME-ca.crt

