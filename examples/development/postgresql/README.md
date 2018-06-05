# About this example

This example runs Portus using PostgreSQL instead of MySQL. This is achieved
through environment variables. You have to set `PORTUS_DB_ADAPTER` to
`postgresql` so this RDBMS is picked instead of the default MYSQL adapter.

## How to run this example

This example is similar to the `docker-compose.yml` file from the root of the
project, but using PostgreSQL. If you want to use it, perform the following
commands (from the root of the project):

```
$ cp examples/postgresql/docker-compose.yml docker-compose.postgres.yml
$ docker-compose -f docker-compose.postgres.yml up
```

## Tips for production

If you want to run PostgreSQL and Portus in production, having to call `bundle`
when bringing up the containers is a bad idea. Instead, create a new Docker
image that derives from the [official Portus
image](https://hub.docker.com/r/opensuse/portus/) and install the `pg` gem
there.
