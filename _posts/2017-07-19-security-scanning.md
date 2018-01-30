---
title: Security scanning
author: Miquel Sabaté Solà
layout: blogpost
---

One of the perks of working at SUSE are [hackweeks](https://en.opensuse.org/Portal:Hackweek). A hackweek is a period
of 5 days in which every employee is free to work on whatever they want. Portus
was born this way, as Flavio explained in his [blog post](https://flavio.castelli.me/2015/04/23/introducing-portus-a-user-interface-for-docker-registry/), and we are happy
to say that the feature announced today was also started this way.

## Adding security features into Portus

We value security at SUSE, and particularly in our team, we think that security
in Docker images and containers is really important. Luckily for us, we are not
alone, and we have witnessed lots of interesting projects springing up from the
community. In this regard, we have contributed to the community
with [zypper-docker](https://github.com/SUSE/zypper-docker), a tool that allows you to patch and monitor Docker
images.

Moreover, as other projects like [Docker hub](https://hub.docker.com/) and [Quay](https://quay.io/) have proven, it's
pretty useful that the same web application that allows you to manage your
Docker images, also fetches security information about them. Because of all
this, we thought that it would be a good idea to create a new layer in Portus,
in which we could integrate security tools, and finally report back about the
security status of the images on your on-premise Docker registry. After toying
with the idea, [Vítor Avelino](https://github.com/vitoravelino) and I worked on this and we have just
recently [merged it all into master](https://github.com/SUSE/Portus/pull/1289).

## How to use it

First of all, this feature is disabled by default, and the configuration part
for it looks like this (inside of the `config/config.yml` file, see [the
documentation on how to configure Portus](/docs/Configuring-Portus.html)):

```yaml
security:
  clair:
    server: ""
  zypper:
    server: ""
  dummy:
    server: ""
```

This feature is enabled through backends. That is, you can enable multiple
backends and Portus will aggregate all the information for each image and
tag. To enable a backend, you have to provide the server URL for the security
scanner. We are currently supporting three backends (even though we only
recommend one of them for now):

- [CoreOS Clair](https://github.com/coreos/clair): Clair is an open source project for the static analysis of
  vulnerabilities in application containers (currently including appc and
  Docker).
- [zypper-docker](https://github.com/SUSE/zypper-docker): zypper-docker is a command line tool that provides a quick
  way to patch and update Docker Images based on either SUSE Linux Enterprise or
  openSUSE. In a hackweek we started to work on a `serve` command, so it can be
  used as a server (see [this branch](https://github.com/SUSE/zypper-docker/tree/cli-separation)). However, we never managed to fully
  stabilize this branch, so support for this is considered experimental.
- The `dummy` backend: this backend is only meant to be used for development
  purposes. That is, it allows developers to have some fixtures that they can
  use.

If you have enabled this feature, you should be able to see something like this
in a repository:

![Repository page with vulnerabilities highlighted](/images/docs/security.png)

Clicking these links will take you to the tag's page. For example:

![Tag page with Clair vulnerabilities](/images/docs/tag-vulnerabilities.png)

## Availability

This feature will be available as of Portus 2.3, but you can already try it out
on the master branch. You can read more about this feature in
the [documentation](/features/6_security_scanning.html).
