#!/usr/bin/env bash

set -ex

##
# Auxiliar functions

PORTUS_DB_ADAPTER=${PORTUS_DB_ADAPTER:-mysql2}

# Interacts with a daemon by taking two arguments:
#   1. The action (e.g. "start").
#   2. The service (e.g. "mysql").
# We do this to abstract the fact that Travis CI does not use systemd and we do.
function __daemon() {
    if [[ -z "$CI" ]]; then
        sudo systemctl $1 $2
    else
        sudo service $2 $1
    fi
}

# Performs systemctl calls to the current database adapter when used outside of
# a container.
function __database() {
    if [[ -f /.dockerenv ]]; then
        return
    fi

    if [[ "$PORTUS_DB_ADAPTER" == "mysql2" ]]; then
        __daemon $1 mysql
    else
        __daemon $1 postgresql
    fi
}

# Setup an insecure registry for the local docker.
function __docker_insecure() {
    if [[ ! -z "$CI" ]]; then
        sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries" : ["172.17.0.1:5000"]
}
EOF
    fi
    __daemon restart docker

    # Show version info
    docker --version
    docker-compose --version
}

##
# The actual run

# Test commit messages
bundle exec rake test:git

# Style and security checks
bundle exec rubocop -V
bundle exec rubocop --extra-details --display-style-guide --display-cop-names

# Compile assets
bundle exec rake portus:assets:compile

# Ruby tests
__database restart
bundle exec rspec spec
__database stop
# if [[ ! -f /.dockerenv ]]; then
#     __docker_insecure
#     bundle exec rake test:integration
# fi

# Note: it ignores a couple of files which use ruby 2.5 syntax which brakeman
# does not know how to handle...
bundle exec brakeman --skip-files lib/portus/background/sync.rb,lib/portus/registry_client.rb

# Make sure that there are no annotations needed.
bundle exec rake portus:annotate_and_exit

# JavaScript tests and style.
yarn test
yarn eslint
