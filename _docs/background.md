---
layout: default
title: The background process
longtitle: The background process needed to keep Portus in sync with other components
order: 5
---

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

# What's the background process?

Every production-ready deployment of Portus must have a process/container called
background which performs some needed tasks for the normal operation of Portus.

If you are running bare metal, you can simply run this process from the source
code:

```
$ bundle exec rails r bin/background.rb
```

That being said, unless you are in a development environment, you won't have to
perform that command. Instead, if you are using the official [Docker
image](https://hub.docker.com/r/opensuse/portus/tags/), you will have to set the
following environment variable: `PORTUS_BACKGROUND=true`. This has been already
set in the [examples that we
provide](https://github.com/SUSE/Portus/tree/master/examples).

## Tasks

As documented above, the background process consists of some tasks that have to
be performed in order to have Portus running properly. These tasks are described
in the sections below.

### Registry events

As explained in [this
section](/features/1_Synchronizing-the-Registry-and-Portus.html#webhooks),
Portus keeps track of the events sent by the Registry itself. This way, in
real-time Portus keeps track of images/tags that have been pushed/deleted.

Before this implementation, this was done synchronously, which led into some
blocking issues.

This task can be disabled as described
[here](/docs/Configuring-Portus.html#background-process), but it is **highly
discouraged** to do so.

### Registry synchronization

All Docker registries provide an API in which any client can fetch some
information. Portus makes a heavy use of this API, and in this case it fetches
the catalog of Docker images/tags. This is done periodically, and it will update
the database when needed.

Just like the other tasks, this task can be disabled, but we recommend tuning
the `strategy` option as described
[here](/docs/Configuring-Portus.html#background-process) instead. For that, you
have to consider when do you think this synchronization has to be performed, and
what should be its reach. In this case you have three possible scenarios:

1. It's the first time you setup your own registry and Portus (i.e. you are
   starting from scratch). In this situation the default value (*initial*) is
   good enough: it will simply do nothing and it will get disabled.
2. You already have a private Docker Registry and you are setting Portus to
   connect to this one. The default value is again the best one because it will
   import the images from this registry and then it will get disabled. That is,
   the `sync` task will act as a registry importer.
3. Regardless of the above cases, you want to guarantee that the database and
   the Docker registry will never be out of sync. In this case you might want to
   set the *update-delete* option (or its safer option *update*). The chance of
   the database to be out of sync with the Docker registry is *highly
   unlikely*. This is why we still recommend leaving the default value, since
   the *update-delete* strategy is prone to be dangerous (its safer sibling
   *update* shouldn't be that potentially dangerous).

Regardless of our recommendations, we suggest you to go to the
[section](/docs/Configuring-Portus.html#background-process) of the documentation
where we describe all options.

**Note**: this was done by the *crono* process before this new
implementation. The old behavior of the old *crono* process corresponds to the
actual *update-delete* strategy.

### Security scanning

If you have [security scanning](/features/6_security_scanning.html) enabled,
then this process will also fetch vulnerabilities so it can be used later by the
user interface.
