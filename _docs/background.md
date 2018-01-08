---
layout: post
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
following environment variable: `PORTUS_INIT_COMMAND=bin/background`. This has
been already set in the [examples that we
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

### Registry synchronization

All Docker registries provide an API in which any client can fetch some
information. Portus makes a heavy use of this API, and in this case it fetches
the catalog of Docker images/tags. This is done periodically, and it will update
the database when needed.

This way Portus makes sure that there are no consistency issues between the
database and the real contents of the registry.

**Note**: this was done by the *crono* process before this new implementation.

### Security scanning

If you have [security scanning](/features/6_security_scanning.html) enabled,
then this process will also fetch vulnerabilities so it can be used later by the
user interface.
