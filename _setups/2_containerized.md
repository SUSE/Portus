---
title: Containerized
order: 2
layout: default
---

## Using the official Docker image in production

In the [examples](https://github.com/SUSE/Portus/tree/master/examples) directory
you can find different containerized deployment examples. All these examples are
using the official
[opensuse/portus](https://hub.docker.com/r/opensuse/portus/tags/) image, which
can be found on Docker Hub, and they are defined in
[opensuse/docker-containers](https://github.com/openSUSE/docker-containers/tree/master/derived_images/portus).
We have the following tags:

- `head`: Portus' master branch packaged and curated as if it was
  production-ready. This is convenient for people that want to be on the
  bleeding edge and want to test the latest features.
- `latest`: the latest stable release.
- Version-specific tags (e.g. `2.3`). We recommend using these tags for
  production clusters.

Moreover, there is also a [Helm
Chart](https://github.com/kubic-project/caasp-services/tree/master/contrib/helm-charts/portus)
that you can use for Kubernetes' clusters.

We do not recommend a deployment method specifically, it is up to you to decide
which one fits better in your case. That being said, you are more than welcome
to share your deployment method in our [mailing
list](https://groups.google.com/forum/#!forum/portus-dev).

### Development

If you simply want to explore Portus and play with it, using the development
environment might be a good fit. A quick way to start a development version of
Portus is to perform the following:

```
$ docker-compose up
```

For more information on development environments, check our
[wiki](https://github.com/SUSE/Portus/wiki#developmentplayground-environments).
