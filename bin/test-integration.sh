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
    echo "[integration] Init file does not exist, downloading into '$ROOT_DIR/bin/integration/init'"
    wget -O $ROOT_DIR/bin/integration/init https://raw.githubusercontent.com/openSUSE/docker-containers/master/derived_images/portus/init
fi
chmod +x $ROOT_DIR/bin/integration/init

# Generate the build directory.
bundle exec rails runner $ROOT_DIR/bin/integration/integration.rb

##
# Start containers.

# It will kill and remove all containers related to integration testing.
cleanup_containers() {
    pushd "$ROOT_DIR/build"
    docker-compose kill
    docker-compose rm -f
    popd
}

if [[ ! "$SKIP_ENV_TESTS" ]]; then
    cleanup_containers
    pushd "$ROOT_DIR/build"
    docker-compose up -d
    popd

    # We will wait 10 minutes until everything is properly set up.
    TIMEOUT=600
    COUNT=0
    RETRY=1

    while [ $RETRY -ne 0 ]; do
        msg=$(SKIP_MIGRATION=1 docker exec $CNAME portusctl exec rails r /srv/Portus/bin/check_db.rb)
        case $(echo "$msg" | grep DB) in
            "DB_READY")
                echo "Database ready"
                break
                ;;
            *)
                echo "Database is not ready yet:"
                echo $msg
                ;;
        esac

        if [ "$COUNT" -ge "$TIMEOUT" ]; then
            echo "[integration] Timeout  reached, exiting with error"
            cleanup_containers
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

# Run tests.
tests=()
if [[ -z "$TESTS" ]]; then
    tests=($ROOT_DIR/spec/integration/*.bats)
else
    for f in $TESTS; do
        tests+=("$ROOT_DIR/spec/integration/$f.bats")
    done
fi
set +e
echo "Running: ${tests[*]}"
bats -t ${tests[*]}
status=$?
set -e

# Tear down
if [[ "$TEARDOWN_TESTS" ]]; then
    cleanup_containers
fi

exit $status
