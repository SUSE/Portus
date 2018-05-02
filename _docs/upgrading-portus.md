---
title: Upgrading Portus
layout: default
order: 6
longtitle: How to upgrade Portus across different versions
---

## Upgrading from 2.2 to 2.3

<div class="alert alert-info">
  <strong>Important note</strong>: before doing anything at all, make sure to
  backup the contents of the database.
</div>

<div class="alert alert-warning">
  <strong>RPM users</strong>: if you had installed Portus from the RPM, follow
  <a href="/docs/migrate-from-rpm.html">these instructions</a> instead.
</div>

Puma is now the HTTP server being used. Make sure to use the
`PORTUS_PUMA_TLS_KEY` and the `PORTUS_PUMA_TLS_CERT` environment variables to
point puma to the right paths for the certificates. Moreover, if you are not
using the official Docker image, you will have to use the `PORTUS_PUMA_HOST`
environment variable to tell Puma where to bind itself (in containerized
deployments it will bind by default to `0.0.0.0:3000`).

The database environment variables have changed the prefix from
`PORTUS_PRODUCTION_` to `PORTUS_DB_`. Moreover, you will be able now to provide
values for the following items: adapter (set it to `postgresql` for PostgreSQL
support), port, pool and timeout. All these values are prefixed by `PORTUS_DB_`
as well, so for example, to provide a value for the pool you need to set
`PORTUS_DB_POOL`.

Finally, we are not running migrations automatically anymore as we used to do
before. This is now to be done by the administrator by executing (on the Portus
context in `/srv/Portus` or simply as part of a `docker exec` command):

```
$ portusctl exec rake db:migrate
```

For more details on this check the commits
[7fdfe9634180](https://github.com/SUSE/Portus/commit/7fdfe96341801b492ca0e2637fcbb0d31e54d5fc)
and
[1c4d2b6cf0e0](https://github.com/SUSE/Portus/commit/1c4d2b6cf0e09e3be770a0675a42ee23cd2f62dd).

## Upgrading from 2.1 to 2.2

<div class="alert alert-info">
  <strong>Important note</strong>: before doing anything at all, make sure to
  backup the contents of the database.
</div>

In order to upgrade from 2.1 to 2.2, you only need to perform a database
migration. So, with the new code in place, simply run the following (wrap it
with `portusctl` if you are using the RPM for openSUSE/SLE):

```
$ rake db:migrate
```

And you should be all set!

## Upgrading from 2.0 to 2.1

### Changes on the configuration

First of all, one of the breaking changes from 2.0 to 2.1 is that the machine
FQDN is no longer considered a secret, but a mere configuration value. In order
to provide a smoother transition, in Portus 2.0.5 we allow the FQDN to be
specified in either the `config/secrets.yml` file or as a proper configurable
value (see [this](https://github.com/SUSE/Portus/commit/f0850459cc43e9b9258e70867d5608f2ef303f3e) commit).
This configurable option is defined like this:

{% highlight yaml %}
machine_fqdn:
  value: "portus.test.lan"
{% endhighlight %}

Therefore, just provide the same value as you had from the `config/secrets.yml`
file, into the `config/config-local.yml` file or the `PORTUS_MACHINE_FQDN_VALUE`
environment variable.

Another breaking change is the `jwt_expiration_time` configuration option. Now,
instead of being a standalone option, it's been put inside of the `registry`
configuration. So, now instead of:

{% highlight yaml %}
jwt_expiration_time
  value: "5.minutes"
{% endhighlight %}

The current configuration is like this:

{% highlight yaml %}
registry:
  jwt_expiration_time:
    value: 5
{% endhighlight %}

Moreover, as you can see, the value of `jwt_expiration_time` has been
simplified. Now, instead of `"5.minutes"` you have to specify it like this
`5`. The expiration time is now represented in minutes, so it no longer needs
to be specified explicitly. The `"5.minutes"` format is still supported, but this
support will be removed in the future.

Besides all that, there have been lots of additions in the configuration that
you can check out [here](/docs/Configuring-Portus.html).

### Upgrading the database

<div class="alert alert-info">
  <strong>Important note</strong>: before doing anything at all, make sure to
  backup the contents of the database.
</div>


With the new code in place, simply run the following (wrap it with `portusctl`
if you are using the RPM for openSUSE/SLE):

```
$ rake db:migrate
$ rake migrate:update_personal_namespaces
```

After that, if you are using an LDAP server for authentication, run the following:

```
$ rake migrate:update_ldap_names
```

The previous task will list the users which are to be updated, and then
it will ask you whether you want to proceed or not. If you don't want this task
to ask you this question (make it non-interactive), simply set the
`PORTUS_FORCE_LDAP_NAME_UPDATE` environment variable before running the rake
task (Note that it will only check the existence of the environment variable,
not its value).

Finally, as an optional step, you might want to execute the following task:

```
$ rake portus:update_tags
```

This task will fill the database with the digest and the image ID of all the
tags stored in the database. This will take a lot of time if you have lots of
images and tags in your Portus instance. For this reason, we recommend setting
the registry to `readonly` mode before performing this operation, just to avoid
any concurrency issues. Moreover, this task also asks for confirmation before
doing anything at all. You can skip this by setting the
`PORTUS_FORCE_DIGEST_UPDATE` environment variable before calling the rake task.
