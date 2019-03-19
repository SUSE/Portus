# Portus

- [Website](http://port.us.org/) | [Documentation](http://port.us.org/documentation.html) | [Blog](http://port.us.org/blog/index.html) | [Supported versions](http://port.us.org/docs/versions.html) | [How to deploy](http://port.us.org/docs/deploy.html)
- Mailing list: [Google Groups](https://groups.google.com/forum/#!forum/portus-dev)
- Last stable release: **2.4.3** (`2.4`, `2.4.3` and `latest` tags from the [official Docker image](https://hub.docker.com/r/opensuse/portus/))

Portus is an authorization server and a user interface for the next generation
of the Docker registry. Portus targets [version
2](https://github.com/docker/distribution/blob/master/docs/spec/api.md) of the
Docker Registry API. The minimum required version of Registry is 2.1, which is
the first version supporting soft deletes of blobs.

| master | v2.4 | Code Climate |
|--------|------|--------------|
| [![Build Status](https://travis-ci.org/SUSE/Portus.svg?branch=master)](https://travis-ci.org/SUSE/Portus) | [![Build Status](https://travis-ci.org/SUSE/Portus.svg?branch=v2.4)](https://travis-ci.org/SUSE/Portus) | [![Code Climate](https://codeclimate.com/github/SUSE/Portus/badges/gpa.svg)](https://codeclimate.com/github/SUSE/Portus) [![Test Coverage](https://codeclimate.com/github/SUSE/Portus/badges/coverage.svg)](https://codeclimate.com/github/SUSE/Portus/coverage) |

## Features

### Fine-grained control of permissions

Portus supports the concept of users and teams. Users have their own personal
Docker namespace where they have both read (aka `docker pull`) and write (aka
`docker push`) access. A team is a group of users that have read and write
access to a certain namespace. You can read more about this in our
[documentation page about
it](http://port.us.org/features/3_teams_namespaces_and_users.html).

Portus implements the [token based authentication
system](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md)
described by the new version of the Docker registry. This can be used to have
full control over the images served by an instance of the Docker registry.

### Web interface for Docker registry

Portus provides quick access to all the images available on your private
instance of Docker registry. User's privileges are taken into account to make
sure private images (the ones requiring special rights also for `docker pull`)
are not shown to unauthorized personnel.

### Self-hosted

Portus allows you to host everything on your servers, on your own
infrastructure. You don't have to trust a third-party service, just own
everything yourself. Take a look at our
[documentation](http://port.us.org/docs/deploy.html) to read the different
setups in which you can deploy Portus.

### And more!

Some highlights:

- [Synchronization with your private registry in order to fetch which images and tags are available](http://port.us.org/features/1_Synchronizing-the-Registry-and-Portus.html).
- [LDAP user authentication](http://port.us.org/features/2_LDAP-support.html).
- OAuth and OpenID-Connect authentication
- [Monitoring of all the activities performed onto your private registry and Portus itself](http://port.us.org/features/4_audit.html).
- [Search for repositories and tags inside of your private registry](http://port.us.org/features/5_search.html).
- [Star your favorite repositories](http://port.us.org/features/6_starring.html).
- [Disable users temporarily](http://port.us.org/features/7_disabling_users.html).
- [Optionally use Application Tokens for better security](http://port.us.org/features/application_tokens.html).

Take a tour by our [documentation](http://port.us.org/features.html) site to
read more about this.

## Contributing

There are multiple ways of setting up a [development
environment](https://github.com/SUSE/Portus/wiki#developmentplayground-environments). We
recommend using `docker-compose`, so you only need to perform:

    $ docker-compose up

You can read more about this environment
[here](https://github.com/SUSE/Portus/wiki/Docker-Compose-Environment).

Also, make sure to understand our contribution guidelines, as explained in
[this](https://github.com/SUSE/Portus/blob/master/CONTRIBUTING.md) document.

### Testing

#### Unit tests

Unit tests are located in the `spec` directory. To run them, simply:

    $ bundle exec rspec spec

Make sure to install [phantomjs](http://phantomjs.org/) from your Linux
distribution before running unit tests, since feature tests rely on PhantomJS
being installed. All the other ruby dependencies are already covered by our
`Gemfile`.

We also have tests in the frontend. For this, you have to install
[yarn](https://yarnpkg.com/) from your Linux distribution and run:

    $ yarn test

#### Integration tests

Check [this
document](https://github.com/SUSE/Portus/blob/master/spec/integration/README.md)
in order to better understand how integration tests work. For development,
though, if you have already installed Docker, docker-composer and
[bats](https://github.com/sstephenson/bats), running the following should just
work:

```
$ chmod +x bin/test-integration.sh
$ ./bin/test-integration.sh
```

#### Other checks

A common pitfall for developers is to forget about code style. For that, make
sure to run [rubocop](https://github.com/bbatsov/rubocop):

    $ bundle exec rubocop -a

Note that the command above includes the `-a` flag. This flag will automatically
fix small issues for you. We also run a code style check for the frontend code:

    $ yarn eslint

We also run [brakeman](https://brakemanscanner.org/) in order to detect security
vulnerabilities:

    $ bundle exec brakeman

Last but not least, make sure that your git commit follows a proper style. To
ensure this, you can run the following task:

    $ bundle exec rake test:git

#### Continuous Integration

We use [Travis CI](https://travis-ci.org/) for continuous integration. You can
run what we run in Travis locally:

```
$ chmod +x bin/ci/run.sh
$ ./bin/ci/run.sh
```

This script simply executes all the tests and checks that we have presented
above.

## Licensing

Portus is licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/SUSE/Portus/blob/master/LICENSE) for the full
license text.
