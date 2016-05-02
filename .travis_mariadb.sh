#!/bin/bash

set -e

OS_CODENAME=$(lsb_release --codename --short)

service mysql stop
apt-get -y purge '^mysql*' 'libmysql*'
apt-get -y install python-software-properties
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

add-apt-repository "deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu $OS_CODENAME main"
apt-get -y update -qq

apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -y install mariadb-server libmariadbd-dev
