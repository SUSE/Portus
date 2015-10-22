#!/bin/bash

set -e

setup_database() {
  set +e

  TIMEOUT=90
  COUNT=0
  RETRY=1

  while [ $RETRY -ne 0 ]; do
    if [ "$COUNT" -ge "$TIMEOUT" ]; then
      printf " [FAIL]\n"
      echo "Timeout reached, exiting with error"
      exit 1
    fi
    echo "Waiting for mariadb to be ready in 5 seconds"
    sleep 5
    COUNT=$((COUNT+5))

    printf "Portus: configuring database..."
    docker-compose run --rm web rake db:create db:migrate db:seed &> /dev/null

    RETRY=$?
    if [ $RETRY -ne 0 ]; then
        printf " failed, will retry\n"
    fi
  done
  printf " [SUCCESS]\n"
  set -e
}

clean() {
  echo "The setup will destroy the containers used by Portus, removing also their volumes."
  if [ $FORCE -ne 1 ]; then
    while true; do
      read -p "Are you sure to delete all the data? (Y/N)" yn
      case $yn in
        [Yy]* )
          break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
      esac
    done
  fi

  docker-compose kill
  docker-compose rm -fv
}

usage() {
  echo "Usage: $0 [-f]"
  echo "  -f force removal of data"
}

# Force the current directory to be named "portus". It's known that other
# setups will make docker-compose fail.
#
# See: https://github.com/docker/compose/issues/2092
if [ "${PWD##*/}" != "portus" ] && [ "${PWD##*/}" != "Portus" ]; then
    cat <<HERE
ERROR: docker-compose is not able to tag built images. Since our compose setup
expects the built image be named "portus_web", the current directory has to be
named "portus" in order to work.
HERE
    exit 1
fi

# Get the docker host by picking the IP from the docker0 interface. This is the
# safest way to reference the Docker host (see issues #417 and #382).
DOCKER_HOST=${DOCKER_HOST=$(/sbin/ifconfig docker0 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -1)}
echo "DOCKER_HOST=${DOCKER_HOST}" > docker/environment

FORCE=0
while getopts "fh" opt; do
  case "${opt}" in
    f)
      FORCE=1
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

clean
docker-compose up -d

setup_database

cat <<EOM

###################
#     SUCCESS     #
###################

EOM

echo "Make sure port 3000 and 5000 are open on host ${DOCKER_HOST}"
printf "\n"

echo "Open http://${DOCKER_HOST}:3000 with your browser and perform the following steps:"
echo "  1 - Create an admin account"
echo "  2 - Add a new registry: choose a custom name, enter ${DOCKER_HOST}:5000 as hostname"
printf "\n"

echo "Perform the following actions on the docker hosts that need to interact with your registry:"
echo " - Ensure the docker daemon is started with the '--insecure-registry ${DOCKER_HOST}:5000'"
echo " - Perform the docker login"
echo "To authenticate against your registry using the docker cli do:"
echo "  docker login -u <portus username> -p <password> -e <email> ${DOCKER_HOST}:5000"
printf "\n"

echo "To push an image to the private registry:"
echo "  docker pull busybox"
echo "  docker tag busybox ${DOCKER_HOST}:5000/<username>busybox"
echo "  docker push ${DOCKER_HOST}:5000/<username>busybox"
