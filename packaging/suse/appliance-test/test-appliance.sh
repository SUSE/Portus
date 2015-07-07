#!/bin/bash
echo 'hello world'
cd /srv/Portus;RAILS_ENV=production INTEGRATION_TESTS=1 bundle exec rake db:drop db:create db:migrate db:seed
docker pull busybox
docker tag -f busybox portus.suse.example.com:5000/busybox
docker login --username=username31 --password=test-password --email=a1@b.com portus.suse.example.com:5000
docker push portus.suse.example.com:5000/busybox
cd /srv/Portus;RAILS_ENV=production bundle exec rails runner 'exit -1 unless PublicActivity::Activity.count == 1'

