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

## Stopping Portus

Prior to anything, we should stop Portus, which means stopping both the Portus Web UI, and
the Portus crono service.

On Version 2.2, and older versions, the Web UI is configured as a virtual host in apache2. Thus,
in order to stop it, you need to disable that configuration. You can do that by running:

```
sudo mv /etc/apache2/vhosts.d/portus.conf /etc/apache2/vhosts.d/portus.conf.disabled
```

Having disabled the vhost configuration, you can stop the crono service by running:

```
sudo systemctl stop portus-crono
```

Once you have portus stopped, you can proceed to back up the data.


## Backing up

After stopping portus, you should proceed as you would with any upgrade: back up your
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
serve as inspiration. These examples are a convenient way of running a similar
plain docker command like:

```
$ docker run -d -v <path-to-certs>:/certificates:ro -p 3000:3000 <list-of-env-variables> opensuse/portus:2.3
```

Moreover, if you are using Kubernetes, you might also be interested in the
[Helm](https://www.helm.sh/) Chart developed
[here](https://github.com/kubic-project/caasp-services/tree/master/contrib/helm-charts/portus).

Regardless of your deployment method, make sure to read some tips that we have
written [here](http://port.us.org/docs/deploy.html#containerized). This will
help you when configuring your deployment methods.

## Removing old RPM

Once you have the new portus container running, it is time to clean up by removing the old Portus RPM.
You can do so by running:

```
zypper rm --clean-deps portus
```

The "clean-deps" option will remove dependencies that are not needed for any other package. This could
be the case of rubygem-passenger-apache2. If you are unsure of this, run the previous command without the
"clean-deps" option.
