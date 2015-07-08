# Portus [![Build Status](https://travis-ci.org/SUSE/Portus.svg?branch=master)](https://travis-ci.org/SUSE/Portus) [![Code Climate](https://codeclimate.com/github/SUSE/Portus/badges/gpa.svg)](https://codeclimate.com/github/SUSE/Portus) [![Test Coverage](https://codeclimate.com/github/SUSE/Portus/badges/coverage.svg)](https://codeclimate.com/github/SUSE/Portus/coverage)

Portus targets [version 2](https://github.com/docker/distribution/blob/master/docs/spec/api.md)
of the Docker registry API. It aims to act both as
an authoritzation server and as a user interface for the next generation of the
Docker registry.

![preview](https://raw.githubusercontent.com/SUSE/Portus/master/doc/portus.png)

## Features

### Fine-grained control of permissions

Portus supports the concept of users and teams. Each user has its personal Docker namespace where she has read (aka `docker pull`) and write (aka `docker push`) access.

A team is a group of users that have read and write access to a certain namespace.

Portus implements the [token based authentication system](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md)
described by the new version of the Docker registry. This can be used to have full control over the images served by an instance of the Docker registry.

### Web interface for Docker registry

Portus provides quick access to all the images available on your private instance of Docker registry. User's privileges are taken into account to make sure private images (the ones requiring special rights also for `docker pull`) are not shown to unauthorized personnel.

## Current limitations

Portus' knowledge of the images available on the private instance of a Docker registry is built using the [notifications](https://github.com/docker/distribution/blob/master/docs/notifications.md) sent by the Docker registry itself.

If Portus is unreachable when a new image is being pushed to the Docker registry, Portus won't be aware of it. This issue is going to be solved by next versions of Portus.

## Development environment

### Docker

It is possible to use docker-compose to spin up a small development/demo
environment.

The environment consists of two Docker containers linked together:

  * web: this is the container running Portus. It's based on the
    [official rails](https://registry.hub.docker.com/_/rails/) Docker image.

  * db: this is the container running the database required by Portus. It's
    based on the
    [official mariadb](https://registry.hub.docker.com/_/mariadb/) Docker image.

First of all ensure you have [docker-compose](https://www.docker.com/docker-compose)
installed. Then do:

```
docker-compose up
```

This will:
  * download the `rails` Docker image from the Docker Hub
  * build the `web` Docker image
  * download the `mariadb` docker image from the Docker Hub
  * start the `db` container and link it against a running insitance of the `web` container.

The next step is to create Portus' database:

```
docker-compose run web rake db:create
```

Then populate the database by running Rails' migrations (**note well:** this
might need to be done from time to time, when new migrations are added):

```
docker-compose run rake db:migrate
```

Now everything is ready to be used. Portus' UI will be accessible on
[http://localhost:3000](http://localhost:3000).

#### Demo

[![asciicast](https://asciinema.org/a/23185.png)](https://asciinema.org/a/23185)

### Vagrant

This project contains a Vagrant based development environment which consists of
three nodes:

  * `registry.test.lan`: this is the node running the next generation of the
    Docker registry.
  * `portus.test.lan`: this is the node running portus itself.
  * `client.test.lan`: a node where latest version of Docker is installed

All the nodes are based on openSUSE 13.2 x86\_64. VirtualBox is the chosen
provisioner.

Port 80 of the `portus` node is forwarded to port 5000 of the machine running
the hypervisor. This makes possible to access Portus' web interface from the
development laptop.

At the same time all the Portus' checkout is shared inside of all the boxes
under the `/vagrant` path. That makes possible to develop portus on your laptop
and have the changes automatically sent to the `portus` box.

**Note well:** this is just a development environment. Portus is running with
`RAILS_ENV` set to `development`. The communication between all the nodes is
not protected by ssl.

## Licensing

Portus is licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/SUSE/Portus/blob/master/LICENSE) for the full
license text.
