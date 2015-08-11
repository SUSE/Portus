# Portus [![Build Status](https://travis-ci.org/SUSE/Portus.svg?branch=master)](https://travis-ci.org/SUSE/Portus) [![Code Climate](https://codeclimate.com/github/SUSE/Portus/badges/gpa.svg)](https://codeclimate.com/github/SUSE/Portus) [![Test Coverage](https://codeclimate.com/github/SUSE/Portus/badges/coverage.svg)](https://codeclimate.com/github/SUSE/Portus/coverage)

Portus targets [version 2](https://github.com/docker/distribution/blob/master/docs/spec/api.md)
of the Docker registry API. It aims to act both as
an authoritzation server and as a user interface for the next generation of the
Docker registry.

[![preview](https://cloud.githubusercontent.com/assets/22728/9194960/98068e1e-401f-11e5-8270-f9e54a6142c0.png)](https://www.youtube.com/watch?v=hGqvYVvdf7U)

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
