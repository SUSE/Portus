---
layout: default
title: Security scanning
order: 5
longtitle: Configuring a security scanner to improve the security from your images
---

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

## Intro

You can setup a security scanner for your Portus instance. This way, Portus will
display whether the images you have on your registry have known security
vulnerabilities. This feature is disabled by default, but it can be configured
through the following values:

```yaml
security:
  # CoreOS Clair support (https://github.com/coreos/clair). This is only
  # guaranteed to work for v2.0.x releases of Clair.
  clair:
    server: ""

    # Port where Clair exposes the health endpoint.
    # See http://port.us.org/features/health.html
    health_port: 6061

  # zypper-docker can be run as a server with its `serve` command. This backend
  # fetches the information as given by zypper-docker. Note that this feature
  # from zypper-docker is experimental and only available through another branch
  # than master.
  #
  # NOTE: support for this is experimental since this functionality has not
  # been merged into master yet in zypper-docker.
  zypper:
    server: ""

  # This backend is only used for testing purposes, don't use it.
  dummy:
    server: ""
```

Portus supports having multiple scanners enabled at the same time.

## CoreOS Clair

<div class="alert alert-info">
  Clair support is only guaranteed to work for <strong>v2.0.x</strong> releases
  of Clair.
</div>

[CoreOS Clair](https://coreos.com/clair/docs/latest/) is an open source project
for the static analysis of vulnerabilities in appc and docker containers. Portus
only supports the analysis of docker images. In order to enable this backend,
you have to pass the URL of your Clair server. For example (or simply with the
`PORTUS_SECURITY_CLAIR_SERVER` environment variable):

```yaml
security:
  clair:
    server: "http://my.clair.server:6060"
```

If you have enabled this backend, you should be able to see something like this
in a repository:

![Repository page with vulnerabilities highlighted](/images/docs/security.png)

Clicking these links will take you to the tag's page. For example:

![Tag page with Clair vulnerabilities](/images/docs/tag-vulnerabilities.png)

## Others

There are two other available backends:

- **zypper-docker**: this is an experimental backend that uses a branch that is
  still under development in [zypper-docker](https://github.com/SUSE/zypper-docker).
- **dummy**: this should only be used for development purposes.
