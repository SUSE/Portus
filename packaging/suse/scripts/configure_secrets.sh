#!/bin/bash

if [[ $(id -u) -ne 0 ]] ;then
  echo "Please run as root"
  exit 1
fi

bundle="/srv/Portus/vendor/bundle/ruby/2.1.0/bin/bundler.ruby2.1"
export GEM_PATH=/srv/Portus/vendor/bundle/ruby/2.1.0/
pushd /srv/Portus

export SKIP_MIGRATION=yes
export RAILS_ENV=production
if [ ! -f /etc/apache2/vhosts.d/portus.conf ];then
  cp /srv/Portus/packaging/suse/conf/etc.apache2.vhosts.d.portus.conf /etc/apache2/vhosts.d/portus.conf
fi
echo "Generating secrets"
SECRET=$($bundle exec rake secret)
sed -e "s/SetEnv PORTUS_SECRET_KEY_BASE.*/SetEnv PORTUS_SECRET_KEY_BASE $SECRET/g" -i /etc/apache2/vhosts.d/portus.conf

popd

