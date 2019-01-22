#!/usr/bin/env bash

set -e

##
# Initial checks

type bats >/dev/null 2>&1 || { echo >&2 "Bats is required. See https://github.com/sstephenson/bats"; exit 1; }

##
# Set up the build directory.

# Exported because it will be re-used by bats.
export ROOT_DIR="$( cd "$( dirname "$0" )/.." && pwd )"
export CNAME="integration_portus"
export RNAME="integration_registry"

# Download the `init` script if possible.
if [ ! -f "$ROOT_DIR/bin/integration/init" ]; then
    echo "[integration] Init file does not exist, creating '$ROOT_DIR/bin/integration/init'"
    cp $ROOT_DIR/docker/init $ROOT_DIR/bin/integration/init
fi
chmod +x $ROOT_DIR/bin/integration/init

##
# Functions for starting/cleaning containers and running tests.

# It will kill and remove all containers related to integration testing.
cleanup_containers() {
    pushd "$ROOT_DIR/build"
    docker-compose -f $1 kill
    docker-compose -f $1 rm -f
    popd
}

# Start the containers depending on the profile to be picked.
start_containers() {
    if [[ ! "$SKIP_ENV_TESTS" ]]; then
        cleanup_containers $1
        pushd "$ROOT_DIR/build"
        docker-compose -f $1 up -d
        popd

        # We will wait 10 minutes until everything is properly set up.
        TIMEOUT=600
        COUNT=0
        RETRY=1

        DB=0
        LDAP=0

        while [ $RETRY -ne 0 ]; do
            set +e
            docker exec $CNAME portusctl exec rails r /srv/Portus/bin/health.rb
            if [ $? -eq "0" ]; then
                response=$(curl --write-out %{http_code} --silent --output /dev/null 172.17.0.1:3000/api/v1/_ping)
                if [ "$response" = "200" ]; then
                    set -e
                    echo "We are all set, let's go!"
                    break
                else
                    echo "Waiting for the portus service to be ready..."
                fi
            else
                echo "Waiting for services to be ready..."
            fi
            set -e


            if [ "$COUNT" -ge "$TIMEOUT" ]; then
                echo "[integration] Timeout  reached, exiting with error"
                cleanup_containers $1
                exit 1
            fi

            sleep 5
            COUNT=$((COUNT+5))
        done

        echo "You may want to set the 'SKIP_ENV_TESTS' env. variable for successive runs..."

        # Travis oddities...
        if [ ! -z "$CI" ]; then
            sleep 10
        fi
    fi
}

# Run tests.
run_tests() {
    tests=()
    if [[ -z "$TESTS" ]]; then
        tests=($ROOT_DIR/spec/integration/$1*.bats)
    else
        for f in $TESTS; do
            tests+=("$ROOT_DIR/spec/integration/$1$f.bats")
        done
    fi
    echo "Running: ${tests[*]}"
    bats -t ${tests[*]}
}

##
# Setup environment

# Build the image if needed.
if [[ -z "$PORTUS_INTEGRATION_BUILD_IMAGE" ]]; then
    pushd $ROOT_DIR
    if [ -z "$CI" ]; then
        docker rmi -f opensuse/portus:development
    fi
    if [[ "$(docker images -q opensuse/portus:development 2> /dev/null)" == "" ]]; then
        docker build -t opensuse/portus:development .
    fi
    popd
fi

# We build the development image only once.
export PORTUS_INTEGRATION_BUILD_IMAGE=false

# Integration tests will play with the following images
export DEVEL_NAME="busybox"
export DEVEL_IMAGE="$DEVEL_NAME:latest"
if [[ "$(docker images -q $DEVEL_IMAGE 2> /dev/null)" == "" ]]; then
    docker pull $DEVEL_IMAGE
fi

# Remove current build directory
rm -rf "$ROOT_DIR/build"

##
# Profiles

profiles=()
if [[ -z "$PROFILES" ]]; then
    profiles=("clair" "ldap")
else
    for p in $PROFILES; do
        profiles+=("$p")
    done
fi

##
# Actual run.

for p in ${profiles[*]}; do
    export PORTUS_INTEGRATION_PROFILE="$p"
    bundle exec rails runner $ROOT_DIR/bin/integration/integration.rb
    start_containers "docker-compose.$p.yml"

    prefix=""
    if [ "$p" != "clair" ]; then
        prefix="$p/"
    fi

    set +e
    run_tests $prefix
    status=$?
    set -e

    if [[ ! -z "$TEARDOWN_TESTS" ]]; then
        cleanup_containers "docker-compose.$p.yml"
    fi

    if [ $status -ne 0 ]; then
        exit $status
    fi
done

exit 0
