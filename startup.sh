#!/bin/sh
# Start portus

cd /portus

if [ "$PORTUS_KEY_PATH" != "" -a "$PORTUS_MACHINE_FQDN" != "" -a ! -f "$PORTUS_KEY_PATH" ];then
    # create self-signed certificates
    echo Creating Certificate
    PORTUS_CRT_PATH=`echo $PORTUS_KEY_PATH|sed 's/(\.key)$/.crt'`
    openssl req -x509 -newkey rsa:2048 -keyout "$PORTUS_KEY_PATH" -out "$PORTUS_CRT_PATH" -days 365 -nodes -subj "/CN=$PORTUS_MACHINE_FQDN"
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

