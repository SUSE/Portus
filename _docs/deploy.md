---
layout: default
title: Deploying Portus
order: 2
longtitle: How Portus can be deployed
---

<div class="alert alert-info">
  Some of the statements from this page rely on Portus <strong>2.3 or
  later</strong>.
</div>

## Containerized

### Docker

The **recommended** way to deploy Portus is with the [official Docker
image](https://hub.docker.com/r/opensuse/portus/). This image is built from the
[main](https://github.com/SUSE/Portus/tree/master/docker) repository. Long story
short, this image downloads the [official
RPM](https://build.opensuse.org/project/show/Virtualization:containers:Portus)
and provides an `init` script which is good for any kind of container
deployment.

This Docker image has in turn a tag policy worth mentioning:

- `head`: Portus' master branch packaged and curated as if it was
  production-ready. This is convenient for people that want to be on the
  bleeding edge and want to test the latest features. It's not recommended to
  use this tag in production since it might break every now and then.
- `latest`: the latest stable release.
- Version-specific tags (e.g. `2.3`). We recommend using these tags for
  production clusters.

Once you have decided to use the Docker image for your deployment, you have to
be aware of the following requirements:

- Configurable values follow a naming policy described
  [here](/docs/Configuring-Portus.html). This page will clarify any doubts you
  may have on how to configure Portus. There are some configurable values which
  are important on production environments:
  - `PORTUS_MACHINE_FQDN_VALUE`: this defines the FQDN to be used. This is
    important because the JWT token passed between Portus and the registry
    relies on this setting. The default value for this will most probably *not*
    work for you.
  - `PORTUS_CHECK_SSL_USAGE_ENABLED`: this is set to true by default, but you
    might want to set it to false in case you are not using SSL.
  - `RAILS_SERVE_STATIC_FILES`: whether you want Portus to serve assets directly
    or not. You can read more about this [here](/docs/assets.html).
  - `CCONFIG_PREFIX`: set this to `PORTUS` just to be sure (it shouldn't be
    necessary, but some deployments have had weird bugs because of this in the
    past).
  - `PORTUS_BACKGROUND`: set to `true` if the container has to execute the
    [background process](/docs/background.html) instead of the main Portus
    process.
- Check the environment variables to be used for the
  [database](/docs/database.html).
- You have to provide three environment variables which contain secret data
  (read [this page](/docs/secrets.html) in order to know how to manage/update
  these secrets in production):
  - `PORTUS_SECRET_KEY_BASE`: which will be used for to encrypt and sign
    sessions (you can read more about this
    [here](http://guides.rubyonrails.org/security.html)).
  - `PORTUS_KEY_PATH`: used to generate the private key for JWT requests (how
    Portus communicates with the Registry safely).
  - `PORTUS_PASSWORD`: the password of the special `portus` user (used for
    maintenance purposes). You cannot change the password of this hidden user as
    you would do with other users. Instead, you have to update this secret and
    restart Portus.
- *Advanced*: the [official Docker
  image](https://hub.docker.com/r/opensuse/portus/) assumes that you only want
  to expose the Puma process externally (the actual process running
  Portus). However, in some unusual deployments (such as the one described
  [here](https://flavio.castelli.me/2018/07/18/hackweek-project-docker-registry-mirror/)),
  you may want to expose this process only in a Unix socket (i.e. in short,
  because you are sharing this socket with other processes). If you want Portus
  to do this, you have to set the `PORTUS_PUMA_USE_UNIX_SOCKET` environment
  variable to `"true"`. Note that the default behavior should be fine for the vast
  majority of deployments, so only touch this if you are *really* sure about
  what you are doing.

Finally, you might want to take a look at some of the examples based on
docker-compose that we have implemented
[here](https://github.com/SUSE/Portus/tree/master/examples/compose).

### Kubernetes and Helm

Unless you are managing Docker containers manually, or you want to deploy
everything in a single machine (in which case you might probably want to check
[this examples](https://github.com/SUSE/Portus/tree/master/examples/compose)),
you will use a Container Orchestrator. There are a wide variety of them, but in
openSUSE and SUSE we quite are invested in Kubernetes (see the [kubic
project](https://github.com/kubic-project)).

Moreover, to maintain Kubernetes applications the community has developed
[Helm](https://helm.sh). Because of this, we have been working on proper Helm
charts to deploy Portus in your Kubernetes cluster. We are working on pushing
these charts into the main repository, but for now you can use the charts from
[this
repository](https://github.com/kubic-project/caasp-services/tree/master/contrib/helm-charts/portus).

### Development

If you simply want to explore Portus and play with it, using the development
environment might be a good fit. A quick way to start a development version of
Portus is to clone the [git repo](https://github.com/SUSE/Portus) and perform
the following:

```
$ docker-compose up
```

For more information on development environments, check our
[wiki](https://github.com/SUSE/Portus/wiki#developmentplayground-environments).

## Bare metal

You can also deploy Portus in a more traditional way: simply installing the code
somewhere and setup a load balancer (we recommend the
[containerized](/docs/deploy.html#containerized) though). In order to install
Portus, you have two options:

1. You clone the [git repository](https://github.com/SUSE/Portus).
2. You install the
   [RPM](https://build.opensuse.org/project/show/Virtualization:containers:Portus)
   if you are using openSUSE or SLE.

After that, you will have to setup everything as any other Rails
application. You have an example of an [NGinx configuration
here](https://github.com/SUSE/Portus/blob/master/examples/compose/nginx/nginx.conf). This
example relies on Puma, and you might want to use the [default Puma
configuration](https://github.com/SUSE/Portus/blob/master/config/puma.rb). The
[init file](https://github.com/SUSE/Portus/blob/master/docker/init) from the
official Docker image might give you some ideas on the environment variables to
be set before starting the whole thing.
