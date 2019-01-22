#!/usr/bin/env bash

set -ex

if [ "$PORTUS_CI" = "unit" ] || [ "$PORTUS_CI" = "all" ]; then
  mysql -e 'create database portus_test;'
  psql -c 'create database portus_test' -U postgres

  # Fix for chrome headless
  export DISPLAY=:99.0 && sh -e /etc/init.d/xvfb start && sleep 3

  # Code climate,
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
  chmod +x ./cc-test-reporter
  ./cc-test-reporter before-build
fi
