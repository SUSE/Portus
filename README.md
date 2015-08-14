# Portus [![Build Status](https://travis-ci.org/SUSE/Portus.svg?branch=master)](https://travis-ci.org/SUSE/Portus) [![Code Climate](https://codeclimate.com/github/SUSE/Portus/badges/gpa.svg)](https://codeclimate.com/github/SUSE/Portus) [![Test Coverage](https://codeclimate.com/github/SUSE/Portus/badges/coverage.svg)](https://codeclimate.com/github/SUSE/Portus/coverage)

Portus targets [version 2](https://github.com/docker/distribution/blob/master/docs/spec/api.md)
of the Docker registry API. It aims to act both as
an authoritzation server and as a user interface for the next generation of the
Docker registry.

[![preview](https://cloud.githubusercontent.com/assets/22728/9274870/897410de-4299-11e5-9ebf-c6ecc1ae7733.png)](https://www.youtube.com/watch?v=hGqvYVvdf7U)

## Features

### Fine-grained control of permissions

Portus supports the concept of users and teams. Each user has its personal Docker namespace where she has read (aka `docker pull`) and write (aka `docker push`) access.

A team is a group of users that have read and write access to a certain namespace.

Portus implements the [token based authentication system](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md)
described by the new version of the Docker registry. This can be used to have full control over the images served by an instance of the Docker registry.

### Web interface for Docker registry

Portus provides quick access to all the images available on your private instance of Docker registry. User's privileges are taken into account to make sure private images (the ones requiring special rights also for `docker pull`) are not shown to unauthorized personnel.

### Synchronization between the database and the registry

Portus' knowledge of the images available on the private instance of a Docker
registry is built in two ways:

1. Using the [notifications](https://github.com/docker/distribution/blob/master/docs/notifications.md)
sent by the Docker registry itself.
2. Using the [Catalog API endpoint](https://github.com/docker/distribution/blob/master/docs/spec/api.md#listing-repositories).

The two methods complement each other. The first method is used to retrieve
updates on the registry in real time, and the second one is used to
double-check the consistency of the database with the registry. To read more on
this topic, don't hesistate to check the [wiki
page](https://github.com/SUSE/Portus/wiki/Synchronizing-the-Registry-and-Portus)
about it.

## Contributing

First of all, make sure that you have a working development environment. You
can easily do this with either Docker or Vagrant, as it's explained on the
[wiki](https://github.com/SUSE/Portus/wiki/The-development-environment).

Also, make sure to understand our contribution guidelines, as explained in
[this](https://github.com/SUSE/Portus/blob/master/CONTRIBUTING.md) document.

Happy hacking!

## Licensing

Portus is licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/SUSE/Portus/blob/master/LICENSE) for the full
license text.
