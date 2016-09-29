---
layout: post
title: portusctl
order: 5
longtitle: Configure and manage a Portus instance installed with the RPM
---

## portusctl

**portusctl** is a CLI tool that comes with the
[provided RPM](/docs/setups/1_rpm_packages.html) and it allows administrators to
setup and manage their Portus instance. This tool requires root privileges and
it has the following commands:

- **setup**: configure your Portus instance. It accepts a wide variety of flags
  that can be used to instruct the values to be set for each configurable value
  and more.
- **make_admin**: if called without arguments, it will simply list the usernames
  that are available. Otherwise, if you pass a valid username, then the selected
  user will become an administrator.
- **rake**: run any of the rake tasks defined within Portus.
- **exec**: run an arbitrary command within the context of Portus. More
  precisely, it will run the command by wrapping it with a bundler exec
  call pinned to the context of Portus.
- **logs**: collect all the logs produced by Portus to further debug an incident.

The RPM also includes man pages for **portusctl** and each of its commands. In
there you will be able to read all the available options and some examples of
usage.

## Setting up Portus

The most common use of portusctl is when installing Portus for the first
time. For example, let's say that the Docker registry is running locally. Then,
a simple way of installing and configuring Portus would be (as root):

```
$ zypper in portus
$ portusctl setup --local-registry --db-name=my-db
```

Note that the **setup** command accepts a flag for each of the
[configuration options](/docs/Configuring-Portus.html) available. For example,
if we'd like to enable deletes in our registry, you'd call it this way:

```
$ portusctl setup --local-registry --delete-enable=true --db-name=my-db
```

Another important topic when setting up Portus is the **SSL configuration**. For
testing/development purposes, the `--ssl-gen-self-signed-certs` option is quite
convenient, but for production servers we recommend using the `--ssl-certs-dir`
flag. Note that with the directory specified by `--ssl-certs-dir` portusctl
will look for a certificate key named `<hostname>-ca.key` and a certificate file
named `<hostname>-ca.crt`.

There are a lot of options that you can configure with this command. For this,
make sure to read the documentation on the
[configuration of Portus](/docs/Configuring-Portus.html) and also read the
manuals shipped with the RPM.

## Reporting bugs with portusctl

Another common scenario is reporting a bug. For this, in order to help
developers to discover what's going on, one can perform the following
actions:

```
$ portusctl rake portus:info
$ portusctl logs
```

The first command executes the `portus:info` rake task defined within
Portus. This task will generate detailed output about the current version of
Portus, the configuration being used (with sensible data shadowed with stars)
and so on. The second command will give you a tarball in `/tmp` containing all
the logs that have been produced by Portus. With all this information on your
hands, you will be able to report the issue you are experiencing.

## Advanced usage

As an advanced example, you can use the **exec** command to further inspect your
Portus installation. For example, with the following command you will be able to
access a Ruby environment with Portus loaded in it:

```
$ portusctl exec rails c
```

By executing the previous command, you will enter a different console that
only accepts Ruby code (in which all Portus' code is available!). With this,
and some knowledge of the Ruby programming language, you will be able to perform
tasks such as:

```
> puts User.all
> puts Team.find_by(name: "myteam").namespaces
```

With the previous two commands, you will be able to list all the users on the
system and all the namespaces of the *myteam* team. Needless to say, only do
this if you really know what you are doing! We only recommend this in
development/staging/test environments, or to experienced Ruby on Rails
developers that are just performing read statements for further inspecting
an issue.

## Man pages

Together with Portus' RPM, you will receive the **man pages** for
`portusctl`. In there, you will be able to read more thoroughly about the
capabilities of this tool.
