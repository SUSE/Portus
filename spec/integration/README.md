## Integration tests

### TL;DR

Install docker, docker-compose and
[bats](https://github.com/sstephenson/bats). When developing, run:

    $ ./bin/test-integration.sh

Before submitting a pull request, run:

    $ bundle exec rake test:run

This is already handled by the `bin/ci/run.sh` script though, so run that
instead.

### Dependencies

The test suite expects the host to have installed all the Ruby dependencies for
development/test purposes as specified in the `Gemfile.lock` file. Thus, you
should perform (in the root of the project):

```
$ bundle
```

Besides this, you need Docker, docker-compose and
[bats](https://github.com/sstephenson/bats).

### How to run integration tests

The integration tests go through some stages before completing:

1. A `build` directory is created with all the dependencies of the run
   (i.e. `docker-compose.yml` for the specific versions, config files, etc.).
2. We then run `docker-compose` in the context of this newly created `build`
   directory.
3. Finally we execute the `bats` tests located in `spec/integration` targeting
   the created containers.

All this can be accomplished with a simple command:

    $ bundle exec rake test:run

This is the command we use in Travis CI, and it executes all tests with the
following matrix:

- The Portus and the background containers use a local build of the code
  (i.e. `opensuse/portus:development`), the current stable release and the
  current `head` tag.
- Each version of Portus being tested will use different supported versions of
  the Docker registry.

If all tests have passed... good! You are ready to go. That being said, if some
tests have passed, maybe it's because some image (most commonly `head`) is
currently broken, so don't be afraid and feel free to submit a PR for your
changes nonetheless.

All that being said, when developing this can be *tedious*. There are lots of
tests to be run for lots of different combinations. So, instead of running the
rake test directly, you should be using the `bin/test-integration.sh` script
instead. In short, the rake task simply defines a matrix of combinations, and
then runs this script for each combo. By default, this script will run only the
development combination, so if you just want to perform a quick test on some
changes you are working on, you can simply perform:

    $ ./bin/test-integration.sh

This script is quite flexible and it allows you to define the following
environment variables:

- `SKIP_ENV_TESTS`: use this when running tests against a set of containers
  which already exist (i.e. from a previous run).
- `TESTS`: a space-separated list of tests to be run.
- `TEARDOWN_TESTS`: set this to cleanup your host from running containers after
  tests have finished. This is disabled by default so you can check the logs
  after tests have finished, and to re-use these same containers on successive
  runs with the `SKIP_ENV_TESTS` environment variables.
- `PROFILES`: there are multiple profiles that you can pick when running
  tests. There are two profiles (by default both of them will be selected):
  - `clair`: the tests that are inside of `spec/integration` (without
    subdirectories).
  - `ldap`: the tests that are inside of `spec/integration/ldap`.

As an example, this is how you'd run this script if you are just interesed in
the `spec/integration/push.bats` test:

    $ TESTS="push" ./bin/test-integration.sh

As another example, if you want to run all the LDAP-only tests, you can perform:

    $ PROFILES=ldap ./bin/test-integration.sh

This script will perform the stages described above. As a final note, the first
stage (setting up the `build` directory) is done by another script:
`bin/integration/integration.rb`. You don't need to know much from this script,
besides that it accepts some other environment variables besides the ones
described above and that might be useful on advanced uses:

- `PORTUS_INTEGRATION_BUILD_IMAGE`: set to `false` if you don't want to re-build
  the development image for every single run (i.e. you want to re-use an updated
  image).
- `PORTUS_TEST_INTEGRATION`: a space-separated list of containers with their
  versions. This is the environment variable touched by the rake task described
  above, and it allows users to run variations of the default matrix. For
  example, you can set it like this:
  `PORTUS_TEST_INTEGRATION="portus#myimage:latest registry#registry:mine"`.

### What you need to know when writing tests

Tests are written with `bats`. You can think of it as bash with some extra
utilities for running tests. If you have to write a new file, pick another one
as an example.

When writing tests make sure to use the functions defined in
`helpers.bash`. This file contains quite some useful functions that will prevent
from running into common pitfalls. As an overview:

- Always use `sane_run` when you want to execute an external command
  (e.g. instead of the default `run` function).
- Do *not* run `sane_run` when another helper would suffice. For example, do not
  run `sane_run docker exec $CNAME portusctl exec mycommand` when
  `portusctl_exec mycommand` would suffice.
