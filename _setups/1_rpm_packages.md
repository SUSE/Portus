---
title: RPM packages
order: 1
layout: post
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
execute this).

### Docker registry V2

We maintain packages for Docker registry V2 named
`docker-distribution-registry`. SUSE Linux Enterprise customers can find the
`docker-distribution-registry` inside of the *"Containers"* module. openSUSE
users can find the package inside of the
[Virtualization:containers](https://build.opensuse.org/project/show/Virtualization:containers)
project on the Open Build Service.

## Initial setup

The Portus RPM ships with a cli tool named `portusctl`. This tool can be
run only by the `root` user and makes easier to manage Portus on openSUSE
and SUSE Linux Enterprise systems. To perform the initial setup execute:

    $ portusctl setup

The `setup` command takes multiple parameters. You can see all the options
(and their default values) by typing `portusctl help setup`. Note that you
have to pass the `--local-registry` flag to properly configure a Docker
registry V2 instance running on the same host of Portus.

Note that you don't need your registry to be running in order to perform the
above command. However, if you already had the registry running, you will have
to restart it after executing this command, so it picks the proper
configuration values.

## The default installation

The default installation has:

* Portus served over HTTPS (all the certs are created by `portusctl`).
* Registry (when ran locally on the same host) uses TLS to secure all the
  communications and listening on port 5000.

When you first enter on your Portus instance, you will have to register your
private registry. This is better explained in
[this](/docs/Configuring-the-registry.html) documentation page. In the default
installation (and with the registry running locally), you will have to enter:

* **Name**: whatever value you want.
* **Hostname**: your hostname + ":5000". The hostname being picked is the one
returned by the command `hostnamectl --static status` (or just `hostname -f` if
you are doing all this inside of a Docker container). Therefore, if for example
that command returns `linux.site`, then you will have to enter:
`linux.site:5000`.
* **Use SSL**: as explained above, the default installation *does* use
encryption. Therefore, you have to check this.

### Common pitfalls

- The `portusctl` utility uses the hostname of the current machine to generate
  certificates. This will of course fail if there is no hostname set.
- The ruby version must be 2.1. This can be a problem for example in openSUSE
  Tumbleweed that has both ruby 2.1 and 2.2. This can also be a problem if you
  are using RVM, rbenv or something similar. Therefore, you have to make sure
  that you use the system ruby and that this is ruby 2.1.
