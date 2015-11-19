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
    docker-compose run --rm web rake db:setup &> /dev/null

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
      read -p "Are you sure to delete all the data? (Y/N) " yn
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

if [ -z $DOCKER_HOST ]; then
  # Get the docker host by picking the IP from the docker0 interface. This is the
  # safest way to reference the Docker host (see issues #417 and #382).
  DOCKER_HOST=$(/sbin/ifconfig docker0 | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | head -1)
fi
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

# The cleaned up host. We do this because when the $DOCKER_HOST variable was
# already set, then it might come with the port included.
final_host=$(echo $DOCKER_HOST | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | head -1)

cat <<EOM

###################
#     SUCCESS     #
###################

EOM

echo "Make sure port 3000 and 5000 are open on host ${final_host}"
printf "\n"

echo "Open http://${final_host}:3000 with your browser and perform the following steps:"
printf "\n"
echo "  1. Create an admin account"
echo "  2. You will be redirected to a page where you have to register the registry. In this form:"
echo "    - Choose a custom name for the registry."
echo "    - Enter ${final_host}:5000 as the hostname."
echo "    - Do *not* check the \"Use SSL\" checkbox, since this setup is not using SSL."
printf "\n"

echo "Perform the following actions on the docker hosts that need to interact with your registry:"
printf "\n"
echo "  - Ensure the docker daemon is started with the '--insecure-registry ${final_host}:5000'"
echo "  - Perform the docker login."
printf "\n"
echo "To authenticate against your registry using the docker cli do:"
printf "\n"
echo "  $ docker login -u <portus username> -p <password> -e <email> ${final_host}:5000"
printf "\n"

echo "To push an image to the private registry:"
printf "\n"
echo "  $ docker pull busybox"
echo "  $ docker tag busybox ${final_host}:5000/<username>busybox"
echo "  $ docker push ${final_host}:5000/<username>busybox"
