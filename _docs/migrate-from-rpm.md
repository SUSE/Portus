---
layout: default
title: Migrating from the RPM
order: 8
longtitle: How to migrate from the RPM to a containerized deployment
hidden: true
---

## Migrating from the RPM

During the development cycle of the 2.3 release, we started to focus more and
more on containerized deployments. The [official openSUSE Docker
image](https://hub.docker.com/r/opensuse/portus/) got more attention and it
started to be thinner and easier to deploy. Following current trends, we decided
to make these kinds of deployments the preferred ones in the 2.3 release.

The migration path from a pure RPM installation to a containerized one is not
that big. That's because the Docker image simply installs the RPM as produced in
our [OBS
project](https://build.opensuse.org/project/show/Virtualization:containers:Portus:2.3). So
from the distribution point of view (and the tooling) nothing changes: the
"only" change is to go from a bare metal installation to Docker containers.

## Backing up

First of all, you should proceed as you would with any upgrade: back up your
data. There are two main things you should back up: images stored in the
registry and the database.

The registry can store Docker images in remote locations with the support for
Amazon S3, Microsoft Azure, etc. That being said, you can also store these
images locally with the following configuration:

```yaml
storage:
  filesystem:
    rootdirectory: /my/location
```

This configuration is stored in `/etc/registry/config.yml`, which was
auto-generated if you used the `portusctl setup` command for setting up your RPM
installation. So, now you have to back up the `/my/location` location as pointed
out on the above example.

Finally, you should back up the data stored on the MySQL/MariaDB instance.

## Running containers

At this point you can deploy Portus with Docker images. We maintain some
examples that use `docker-compose`
[here](https://github.com/SUSE/Portus/tree/master/examples/compose) that might
serve as inspiration. Moreover, if you are using Kubernetes, you might also be
interested in the [Helm](https://www.helm.sh/) Chart developed
[here](https://github.com/kubic-project/caasp-services/tree/master/contrib/helm-charts/portus).

Regardless of your deployment method, make sure to read some tips that we have
written [here](http://port.us.org/docs/deploy.html#containerized). This will
help you when configuring your deployment methods.
