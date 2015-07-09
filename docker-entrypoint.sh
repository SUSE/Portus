#!/bin/bash

# Start DB server and reset password to empty
service mysql start >/dev/null
mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('');"

# Setup Portus database
bundle exec rake db:create
bundle exec rake db:migrate

chown -R www-data:www-data /portus

exec "$@"