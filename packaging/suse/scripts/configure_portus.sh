#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

bundle="/srv/Portus/vendor/bundle/ruby/2.1.0/bin/bundler.ruby2.1"
export GEM_PATH=/srv/Portus/vendor/bundle/ruby/2.1.0/
pushd /srv/Portus

export SKIP_MIGRATION=yes
export RAILS_ENV=production
cp /srv/Portus/packaging/suse/conf/etc.apache2.vhosts.d.portus.conf /etc/apache2/vhosts.d/portus.conf
echo "Generating secrets"
SECRET=$($bundle exec rake secret)
sed -e "s/__SECRET_KEY__/$SECRET/g" -i /etc/apache2/vhosts.d/portus.conf

echo "Set pasword"
PP=$(echo $RANDOM)
sed -e "s/__PORTUS_PASSWORD__/$PP/g" -i /etc/apache2/vhosts.d/portus.conf

popd

