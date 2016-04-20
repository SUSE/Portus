#!/bin/bash
# Start portus

if [ "$PORTUS_KEY_PATH" != "" ]; then
   NAME=`basename $PORTUS_KEY_PATH .key`
else
   NAME="registry"
fi
if [ "$PORTUS_PORT" = "" ]; then
    PORTUS_PORT=443
fi
if [ "$PORTUS_MACHINE_FQDN" = "" ]; then
    PORTUS_MACHINE_FQDN=`hostname`
fi
mkdir -p /etc/nginx/conf.d
cat >/etc/nginx/conf.d/portus.conf <<_END_
      server {
        listen 443 ssl;
        ssl_certificate     certs/$NAME.crt;
        ssl_certificate_key certs/$NAME.key;
        location / {
          proxy_set_header Host $PORTUS_MACHINE_FQDN;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Host $PORTUS_MACHINE_FQDN:$PORTUS_PORT;
          proxy_pass http://portus:3000/;
          proxy_http_version 1.1;
          proxy_set_header Connection "upgrade";
          proxy_read_timeout 900s;
        }
      }
_END_

cd /portus

if [ "$PORTUS_KEY_PATH" != "" -a "$PORTUS_MACHINE_FQDN" != "" -a ! -f "$PORTUS_KEY_PATH" ];then
    # create self-signed certificates
    echo Creating Certificate
    PORTUS_CRT_PATH=`echo $PORTUS_KEY_PATH|sed 's/\.key$/.crt/'`
    export ALTNAME=`hostname`
    export IPADDR=`ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1|tail -1`
    openssl req -x509 -newkey rsa:2048 -keyout "$PORTUS_KEY_PATH" -out "$PORTUS_CRT_PATH" -days 3650 -nodes -subj "/CN=$PORTUS_MACHINE_FQDN" -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:registry,DNS:$PORTUS_MACHINE_FQDN,DNS:$ALTNAME,IP:$IPADDR,DNS:portus"))

fi

if [ "$PORTUS_MACHINE_FQDN" != "" ];then
    echo config FQDN into rails
    sed -i"" -e "s/portus.test.lan/$PORTUS_MACHINE_FQDN/" config/config.yml
fi

echo Making sure database is ready
rake db:create && rake db:migrate && rake db:seed

echo Creating API account if required
rake portus:create_api_account

if [ "$PORTUS_PASSWORD" != "" ]; then
echo Creating rancher password
rake "portus:create_user[rancher,rancher@rancher.io,$PORTUS_RANCHER_PASSWORD,false]"
fi

if [ "$REGISTRY_HOSTNAME" != "" -a "$REGISTRY_PORT" != "" -a "$REGISTRY_SSL_ENABLED" != "" ]; then
echo Checking registry definition for $REGISTRY_HOSTNAME:$REGISTRY_PORT
rake sshipway:registry"[Registry,$REGISTRY_HOSTNAME:$REGISTRY_PORT,$REGISTRY_SSL_ENABLED]"
fi

echo Starting chrono
bundle exec crono &

echo Starting Portus
/usr/bin/env /usr/local/bin/ruby /usr/local/bundle/bin/puma $*

