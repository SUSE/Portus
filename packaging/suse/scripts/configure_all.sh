#!/bin/bash
cd $(dirname $0)

./configure_apache.sh
./configure_secrets.sh
./configure_ssl.sh
./configure_database.sh
./create_db.sh
./configure_registry.sh
./configure_ldap.sh

systemctl reload apache2

