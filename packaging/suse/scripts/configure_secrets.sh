#!/bin/bash
cd $(dirname $0)

. check_reqs.include

check_reqs

bundle="/srv/Portus/vendor/bundle/ruby/2.1.0/bin/bundler.ruby2.1"
export GEM_PATH=/srv/Portus/vendor/bundle/ruby/2.1.0/
pushd /srv/Portus

export SKIP_MIGRATION=yes
export RAILS_ENV=production

echo "Generating secrets"
SECRET=$($bundle exec rake secret)
sed -e "s/SetEnv PORTUS_SECRET_KEY_BASE.*/SetEnv PORTUS_SECRET_KEY_BASE $SECRET/g" -i $APACHE_CONF_PATH/portus.conf

popd

