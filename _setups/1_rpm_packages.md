---
title: RPM packages
layout: post
---

## Installing the RPM

Portus can be installed from an RPM package on openSUSE and SUSE Linux
Enterprise system. We provide an up-to-date package from master's snapshots
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

## Portus's dependencies

Portus requires a [MariaDB](https://mariadb.com/) instance running and,
obviously, also a [Docker registry v2](https://github.com/docker/distribution)
instance. Both MariaDB and Docker Registry can run on different hosts.

### Installing MariaDB

You can install MariaDB from the packages shipped with openSUSE/SUSE Linux
Enterprise:

    $ zypper in mariadb

Make sure you invoke `/usr/bin/mysql_secure_installation` to secure your
installation.

### Docker registry V2

We maintain packages for Docker registry V2 named
`docker-distribution-registry`. SUSE Linux Enterprise customers can find the
`docker-distribution-registry` inside of the *"Containers"* module. openSUSE
users can find the package inside of the
[Virtualization:containers](https://build.opensuse.org/project/show/Virtualization:containers)
project on the Open Build Service.

## Initial setup

The Portus RPM ships with a cli tool named `portusctl`. The tool can be
run only by the `root` user and makes easier to manage Portus on openSUSE
and SUSE Linux Enterprise systems. To perform the initial setup execute:

    $ portusctl setup

The `setup` command takes multiple parameters. You can see all the options
(and their default values) by typing `portusctl help setup`. Note that you
have to pass the `--local-registry` flag to properly configure a Docker
registry V2 instance running on the same host of Portus.

## The default installation

The default installation have:

* Portus served over HTTPS (all the certs are created by `portusctl`).
* Registry (when ran locally on the same host) uses TLS to secure all the
  communications and listening on port 5000.

