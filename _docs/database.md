---
layout: default
title: Configuring the database
order: 1
longtitle: How Portus connects to the database and configuration options
---

<div class="alert alert-info">
  This article is only valid for <strong>2.3 or later</strong>.
</div>

This documentation page tries to clear up questions regarding Portus and the
database. If this page is not clear enough, please [submit a new
issue](https://github.com/SUSE/Portus/issues/new) or ask on our [official
mailing list](https://groups.google.com/forum/#!forum/portus-dev).

For further documentation you can also check out some of the
[examples](https://github.com/SUSE/Portus/tree/master/examples).

## Supported database backends

You could theoretically use any database with Portus, but we have decided on two
choices: MariaDB (default) and PostgreSQL. In order to support other RDBMS we
would need to add them in the Gemfile and call `bundle`, which is a burden in
containerized scenarios.

You can pick the adapter with the `PORTUS_DB_ADAPTER` environment variable,
which defaults to `mysql2`. For PostgreSQL you need to set it to `postgresql`.

Support for these adapters require two gems that have to be built natively:

- **mysql2**: this gem needed for MariaDB needs the development files for MySQL
  in order to be installed properly. For openSUSE, these come with the
  `libmysqlclient-devel` package.
- **pg**: for PostgreSQL you will need to install the development files for
  PostgreSQL. For openSUSE, these come with the `postgresql-devel` package.

Note that these dependencies have already been bundled in the [official Portus
image](https://hub.docker.com/r/opensuse/portus/).

## Configuration options

In order to connect to the database, Portus requires more environment
variables. The most important ones being:

- `PORTUS_DB_HOST`: the location of your database. It defaults to `localhost`.
- `PORTUS_DB_USERNAME`: the name of the user accessing the database for
  Portus. It defaults to `root`.
- `PORTUS_DB_PASSWORD`: the password to be used when accessing the database. It
  defaults to an empty string.

Besides this, you can further configure this with other options:

- `PORTUS_DB_PORT`: an alternative port for the database.
- `PORTUS_DB_POOL`: the number of pool connections.
- `PORTUS_DB_TIMEOUT`: the timeout for requests.

When not provided, the options above take the default value of the database
backend.

Last but not least, the name of the database will be `portus_$environment`. So,
for a production environment, it will be `portus_production`. That being said,
you can provide another name with the `PORTUS_DB_DATABASE` environment variable.

## How Portus bootstraps the database

Portus is a Ruby on Rails application, and as such, it connects to the database
through a given `config/database.yml`. This file is filled with the environment
variables documented in the previous section. At this point, Portus is able to
talk to the database, but it has to first sync the schema before doing anything
with it. In order to do so, the usual commands from a Ruby on Rails application
are:

```
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```

If you have installed Portus through the RPM or you are using the [official
Portus image](https://hub.docker.com/r/opensuse/portus/), you can call
`portusctl` instead of `bundle` in order to get the right environment (otherwise
you can simply use `/srv/Portus` as the working directory).

For the containerized scenario though, you have to wait for the database to be
up. This is already done automatically by our official Portus image. If you want
to check whether Portus can access the database, you can perform the following
command:

```
$ portusctl exec rails r bin/check_db.rb
```

## Considerations when deploying a database for Portus

Portus does not require anything specific for the database. Thus, you can deploy
your database cluster in the way you feel it's safer, faster, etc.
