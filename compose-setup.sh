#!/bin/bash

set -e

setup_database() {
  set +e

  TIMEOUT=90
  COUNT=0
  printf "Portus: configuring database..."
  docker-compose run web rake db:create db:migrate &> /dev/null

  while [ $? -ne 0 ]; do
    printf " [FAIL]\n"
    echo "Waiting for mariadb to be ready"
    if [ "$COUNT" -ge "$TIMEOUT" ]; then
      printf " [FAIL]\n"
      echo "Timeout reached, exiting with error"
      exit 1
    fi
    sleep 5
    COUNT=$((COUNT+5))

    printf "Portus: configuring database..."
    docker-compose run web rake db:create db:migrate &> /dev/null
  done
  printf " [SUCCESS]\n"
  set -e
}

clean() {
  echo "The setup will destroy the containers used by Portus, removing also their volumes."
  while true; do
    read -p "Are you sure to delete all the data? (Y/N)" yn
    case $yn in
      [Yy]* )
        docker-compose kill
        docker-compose rm -fv
        break;;
      [Nn]* ) exit 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}


echo "DOCKER_HOST=${HOST}" > docker/environment


clean
docker-compose up -d

setup_database

cat <<EOM

###################
#     SUCCESS     #
###################

EOM

echo "Make sure port 3000 and 5000 are open on host ${HOST}"
printf "\n"

echo "Open http://${HOST}:3000 with your browser and perform the following steps:"
echo "  1 - Create an admin account"
echo "  2 - Add a new registry: choose a custom name, enter ${HOST}:5000 as hostname"
printf "\n"

echo "Perform the following actions on the docker hosts that need to interact with your registry:"
echo " - Ensure the docker daemon is started with the '--insecure-registry ${HOST}:5000'"
echo " - Perform the docker login"
echo "To authenticate against your registry using the docker cli do:"
echo "  docker login -u <portus username> -p <password> -e <email> ${HOST}:5000"
printf "\n"

echo "To push an image to the private registry:"
echo "  docker pull busybox"
echo "  docker tag busybox ${HOST}:5000/<username>busybox"
echo "  docker push ${HOST}:5000/<username>busybox"
