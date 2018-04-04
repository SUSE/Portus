---
layout: default
title: Debugging Portus
longtitle: How to debug problems that may occur
order: 7
---

## Debugging Portus

This page contains several tips that might help you when debugging a problem in
Portus.

### Log level

The log level in production (e.g. the [official Docker
image](https://hub.docker.com/r/opensuse/portus/)) is set to `info`. This is
convenient when everything is alright: it does not pollute logs with lots of
details, but it will report crashes and other errors. That being said, in some
cases reading more detailed debug messages can be quite handy. For example, if
Portus did not authorize an action that should be authorized, you'd want to know
step by step how Portus handled the request.

Portus makes a heavy usage of the Ruby on Rails logging mechanism. So, for most
of the important paths there will be debugging messages that will help you along
the way. All these debug messages are set in the `debug` log level, which is
lower than the default `info`. If you want to change this, then you need to set
the `PORTUS_LOG_LEVEL` environment variable to `debug`. After doing this, you
will be able to read what you read before with the `info` level, plus all the
debug messages mentioned earlier.

Our **recommendation** is that you leave the defaults as they are, since going
down to the debug level can be pretty verbose. When you think you are facing a
problem, or you want to report an issue with the logs, then we recommend that
you set `PORTUS_LOG_LEVEL` to `debug` and then reproduce again your
problem. Once you've got the logs, go back to `info` or unset `PORTUS_LOG_LEVEL`
so you don't get a constant influx of debugging messages.

### Current configuration and Portus version


Sometimes the problem that you are facing is a configuration one. Most commonly,
you wrote a typo (e.g. a typo on an environment variable name), or you are using
a configuration option that doesn't exist (e.g. an option that lies inside of
another section), etc. A good way to make sure that everything is as expected,
is to fetch the evaluated configuration. You can fetch the current configuration
that is being used in Portus by simply calling `portus:info` rake task If you
are using the [official Docker
image](https://hub.docker.com/r/opensuse/portus/), then you only need to
perform:

```
$ docker exec -it <container-id> portusctl exec rake portus:info
```

After executing this command, you will be able to tell if the configuration
values are as expected. If that's not the case, then review the environment
variables you've used and read again [this page](/docs/Configuring-Portus.html).

Moreover, this command will also print the exact version of Portus (with the
commit SHA), which is useful when reporting an issue.
