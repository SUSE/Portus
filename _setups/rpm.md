---
title: RPM packages
layout: default
---

## Installing the RPM

Portus can be installed from an RPM package on openSUSE and SUSE Linux
Enterprise. We provide an up-to-date package from master's snapshots
on a daily basis inside of the [Virtualization:containers:Portus](https://build.opensuse.org/project/show/Virtualization:containers:Portus)
project on the [Open Build Service](http://openbuildservice.org/). Packages
for stable releases of Portus can be found inside of
[dedicated release projects](https://build.opensuse.org/project/subprojects/Virtualization:containers:Portus)
on the Open Build Service.

First of all you need to add the right repository and then install Portus. This
can be done from the command line tool using `zypper` itself, but the
easiest approach is to use *"1-click install"* feature offered by
[software.opensuse.org](http://software.opensuse.org). Just follow
[this](http://software.opensuse.org/package/Portus?search_term=Portus)
link, select the right release of openSUSE/SUSE Linux Enterprise and then click
the *"1-click install"* button.

This will add the right repository to your machine and, at the same time,
install the `Portus` RPM on your system.

## Portus' dependencies

Portus requires a [MariaDB](https://mariadb.com/) instance running and,
obviously, also a [Docker registry v2](https://github.com/docker/distribution)
instance. Both MariaDB and Docker Registry can run on different hosts (that's
why the RPM just recommends these packages, instead of requiring them).

### Installing MariaDB

You can install MariaDB from the packages shipped with openSUSE/SUSE Linux
Enterprise:

    $ zypper in mariadb

Make sure you invoke `/usr/bin/mysql_secure_installation` to secure your
installation (note that you must have MariaDB already running in order to
execute this). Even if Portus might work with older releases of MariaDB, we
recommend using the latest one.

### Docker registry V2

We maintain packages for Docker registry V2 named `docker-distribution`. SUSE
Linux Enterprise customers can find the `docker-distribution` inside of the
*"Containers"* module. openSUSE users can find the package inside of the
[Virtualization:containers](https://build.opensuse.org/project/show/Virtualization:containers)
project on the Open Build Service. If you already have Docker Distribution
installed, make sure that it abides to [our
requirements](/docs/versions.html#docker-and-docker-distribution).
