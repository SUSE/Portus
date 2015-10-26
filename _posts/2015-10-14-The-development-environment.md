---
layout: post
title:  "The development environment"
date:   2015-10-14 17:27:10
categories: documentation
---

This page describes some handy tips about running Portus on development mode.

## Virtualization

### Docker

It is possible to use [docker-compose](https://github.com/docker/compose) to spin up a small development/demo environment. The environment consists of three Docker containers linked together:

* **web**: this is the container running Portus. It's based on the [official rails](https://registry.hub.docker.com/_/rails/) Docker image.
* **db**: this is the container running the database required by Portus. It's based on the [official mariadb](https://registry.hub.docker.com/_/mariadb/) Docker image.
* **registry**: this is a the container running the latest version of the [Docker registry](https://github.com/docker/distribution) (aka distribution). It's based on the [official registry](https://registry.hub.docker.com/_/registry/) Docker image.

This environment is meant for **development/playground** purposes. Known limitations:

  * Portus uses a public and passwordless certificate stored inside of this git repository.
  * Registry is **not** secured, everything is transmitted over http.
  * The Docker host has two open two ports in order to make Portus and the registry reachable.

#### Initial setup

First of all ensure you have [docker-compose](https://www.docker.com/docker-compose) installed. Note that this setup is known to fail on NFS. Then do:

```
$ ./compose-setup.sh
```

This will:
  * Download the `rails` Docker image from the Docker Hub.
  * Build the `portus_web` Docker image.
  * Download the `mariadb` Docker image from the Docker Hub.
  * Start the `portus_db` container and link it against a running instance of the `web` container.
  * Download the `registry` Docker image from the Docker Hub
  * Start the `portus_registry` container and link it against a running instance of the `web` container.
  * Initialize Portus' database: database creation, run the migrations.

Once the setup is done there are a couple of manual operations to perform on Portus:

  * Create your account. The first user is going to be an administrators. Administrators are special users, they can do everything, including pushing to the global namespace of your registry.
  * Associate your on-premise instance of the Docker registry.

The setup script will print all these informations on the console.

Portus' UI will be accessible on `http://<docker host>:3000`.
The registry will be listening on `<docker host>:5000.

#### Normal usage

Once the initial setup is done you can use `docker-compose` to handle everything.

You can do:

  * `docker-compose up` to start the whole environment
  * `docker-compose stop` to stop the whole environment

All the changes (database, registry) are stored into Docker volumes.

#### Demo

[![asciicast](https://asciinema.org/a/24174.png)](https://asciinema.org/a/24174)

### Vagrant

This project contains a Vagrant based development environment which consists of three nodes:

* `registry.test.lan`: this is the node running the next generation of the Docker registry.
* `portus.test.lan`: this is the node running portus itself.
* `client.test.lan`: a node where latest version of Docker is installed

All the nodes are based on openSUSE 13.2 x86\_64. VirtualBox is the chosen provisioner.

Port 80 of the `portus` node is forwarded to port 5000 of the machine running the hypervisor. This makes possible to access Portus' web interface from the development laptop.

At the same time all the Portus' checkout is shared inside of all the boxes under the `/vagrant` path. That makes possible to develop portus on your laptop and have the changes automatically sent to the `portus` box.

**Note well:** this is just a development environment. Portus is running with `RAILS_ENV` set to `development`. The communication between all the nodes is not protected by SSL.

## Bare metal

Maybe you want to write code for Portus with a bare metal setup. This is not recommended, since it might conflict with whatever you might have in your machine. Anyways, here there are some tips:

- Maybe you want to take a look at some setups that are known to work, like [this](https://github.com/SUSE/Portus/wiki/An-NGinx-setup) NGinx setup.
- In the `.gitignore` file we ignore a file named `bin/portus`. You might use this as a script that sets up everything to get Portus working.

As an example of the above, you might configure an NGinx + Puma setup, and then have the following `bin/portus` script:

```bash
#!/bin/bash

# The base directory of the project.
base="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Export environment variables if needed.
if [ -z "$PORTUS_KEY_PATH" ]; then
    export PORTUS_KEY_PATH="/etc/nginx/ssl/registry.mssola.cat.key"
fi
if [ -z "$PORTUS_MACHINE_FQDN" ]; then
    export PORTUS_MACHINE_FQDN="registry.mssola.cat"
fi

# Check which command to use.
cmd="restart"
if [ "$1" != "" ]; then
    cmd="$1"
fi

sudo systemctl $cmd mysql nginx registry

# In Puma a restart can be troublesome. Since this script is used for
# development purposes only, a restart will mean to force the stop and then
# start.
if [ "$cmd" = "restart" ]; then
    if [ -f "$base/tmp/pids/puma.pid" ]; then
        bundle exec pumactl -F $base/../puma.rb stop
    fi
    cmd="start"
fi
bundle exec pumactl -F $base/../puma.rb $cmd
```
