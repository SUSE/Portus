# Portus Official Docker image

This directory contains all the resources needed to create a production-ready
Docker image for Portus.

The master branch of this repository is going to include the files needed
to build Portus from the `master` branch, which is tagged as `head`. Other
branches are available to build Portus out of more stable branches. These
branches are going to be named using the following scheme: `portus-<release>`.

Moreover, note that the deployment method has changed quite a lot:

- From 2.0 to 2.2, Portus uses Apache.
- From 2.3 onwards (including `head`), Portus uses Puma.

This file contains instructions on the Puma deployment. If you want to know more
about how to deploy other versions of Portus, please refer to this file on their
respective branches.

## Security

SUSE's containers team cares about security, hence we made the following
decisions:

  * This image is running in the `production` environment, and because of that
    SSL is enabled by default. You can disable this by setting the
    `PORTUS_CHECK_SSL_USAGE_ENABLED` environment variable to false, but we don't
    recommend this.
  * Portus is installed from an RPM package, this ensures the final image will
    have only the runtime dependency; no build time dependency is ever installed.

SUSE's containers team is constantly working to automate the release process
of Portus and of this image to ensure it stays up-to-date and secure.

When deploying this image make sure to add all the required keys and
certificates at runtime instead of adding them to a Docker image.

## Anatomy of the image

The image is based on openSUSE 42.3 and installs Portus using the RPM package
built by SUSE's containers team inside of the [Open Build Service](https://build.opensuse.org/project/subprojects/Virtualization:containers:Portus)
top level project and subprojects (one subproject per portus branch).

### Exposed ports

This image is using Puma as the web server and it only binds to the `3000`
port.

### The init script

This Docker image has a init script which takes care of the following actions:

  1. Setup the database required by Portus
  2. Import all the `.crt` located under `/certificates`
  3. Start Puma

The next sections will provide more details about these steps.

### Volumes

Portus' state is stored inside of a MariaDB database. This makes this Docker
image stateless.

### External database

This image has a custom `init` script that takes care of configuring the external
database.

The script will keep trying to reach the database for 90 seconds. A 5 seconds
pause is done after each failed attempt. The container will exit with an error
message if the database is not reachable.

The script will take care of the creation of the Portus database and its initial
population via the usual Rails procedures.

The database is automatically migrated whenever a new migration is introduced
by the upstream project.

### Secrets and certificates

Portus requires both a SSL key and a certificate to serve its contents over
HTTPS. These files must be located in the `/certificates` directory of the
container. Moreover, it's up to the deployer to set the `PORTUS_PUMA_TLS_KEY`
and `PORTUS_PUMA_TLS_CERT` environment variables. Note that the key is also
used to sign the JWT tokens issued to authenticate all the docker clients
against the Registry.

It's also required to add the certificate of the Registry when the latter one
uses TLS to secure itself. The Registry certificate must be placed inside
of `/certificates`, the `init` script of this image will automatically import
it if it ends with the `.crt` extension.

This image also supports [Docker
secrets](https://docs.docker.com/engine/swarm/secrets/) for some environment
variables. In particular, setting `PORTUS_DB_PASSWORD_FILE`,
`PORTUS_PASSWORD_FILE`, `PORTUS_SECRET_KEY_BASE_FILE`,
`PORTUS_EMAIL_SMTP_PASSWORD_FILE` and `PORTUS_LDAP_AUTHENTICATION_PASSWORD_FILE`
with the path for the secrets will automatically set `PORTUS_DB_PASSWORD`,
`PORTUS_PASSWORD`, `PORTUS_SECRET_KEY_BASE`, `PORTUS_EMAIL_SMTP_PASSWORD` and
`PORTUS_LDAP_AUTHENTICATION_PASSWORD` respectively with the contents of these
files.

### Logging

All logging is done to `stdout` and `stderr`. This makes it possible to handle
the logs of this image in the usual ways.

## Deployment

It's possible to deploy this image using one of the existing orchestration
solutions for Docker images. You can read some examples in the `examples`
directory of Portus' source code.

### Executing the crono script

Portus uses [crono](https://github.com/plashchynski/crono) to handle some
background jobs. You can also execute this piece with this image. In order to do
this, you need to set the `PORTUS_INIT_COMMAND` environment variable to
"bin/crono".

### Environment variables

Here's the full list of environment variables:

Security related settings:

  * `PORTUS_SECRET_KEY_BASE`: you can generate it using `openssl rand -hex 64`,
    or provide it as a Docker secret with `PORTUS_SECRET_KEY_BASE_FILE`.
  * `PORTUS_KEY_PATH`: the path of the certificate key. This is the key that
    Portus will use for the authentication with your Docker registry.
  * `PORTUS_PASSWORD`: the password of the hidden `portus` user. You can
    generate it using `openssl rand -hex 64`. You can provide a Docker secret by
    setting `PORTUS_PASSWORD_FILE`.
  * `PORTUS_PUMA_TLS_KEY`: The TLS key to be picked by Puma.
  * `PORTUS_PUMA_TLS_CERT`: The TLS certificate to be picked by Puma.
  * `PORTUS_CHECK_SSL_USAGE_ENABLED`: Set this to `false` if you want to disable
    SSL altogether.

Database releated settings (see [configuring the database](http://port.us.org/docs/database.html) for details):

  * `PORTUS_DB_ADAPTER`: database type. Supported values are `postgresql` and `mysql2`. Default is `mysql2`.
  * `PORTUS_DB_HOST`: the host running the MariaDB (or Postgres) database.
  * `PORTUS_DB_USERNAME`: the database user to be used.
  * `PORTUS_DB_PASSWORD`: the password of the database user. You can provide a
    Docker secret by setting `PORTUS_DB_PASSWORD_FILE`.
  * `PORTUS_DB_DATABASE`: the name of the Portus database.
  * `PORTUS_DB_PORT`: alternative database port number.
  * `PORTUS_DB_POOL`: the number of pool connections.
  * `PORTUS_DB_TIMEOUT`: timeout value for requests.

Deployment related settings:

  * `PORTUS_MACHINE_FQDN_VALUE`: this is the fully qualified domain name of your
    Portus instance (eg: `portus.example.com`).

Some fine tuning for Puma:

  * `PORTUS_PUMA_WORKERS`: the amount of Puma workers to be spawned. Defaults to 1.
  * `PORTUS_PUMA_MAX_THREADS`: the maximum amount of Puma threads to be
    created. Defaults to 1.
  * `RAILS_SERVE_STATIC_FILES`: set this to `true` if you want Puma to serve the
    static files. Defaults to false, in which case you'd need for example NGinx
    in front of this container.

Executing other commands:

  * `PORTUS_INIT_COMMAND`: you can set this environment variable with the
    command that you'd like to run. For example, if you want to run crono, you
    can set it to "bin/crono".
  * `PORTUS_BACKGROUND`: you can set this environment to true in order to
    indicate that the process to be executed is the rails runner
    `bin/background.rb` (that is, the background process). This is a shortcut
    for `PORTUS_INIT_COMMAND=rails r /srv/Portus/bin/background.rb`.

You can also pass further environment variables to configure Portus as
described [here](http://port.us.org/docs/Configuring-Portus.html#override-specific-configuration-options).
