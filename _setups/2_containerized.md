---
title: Containerized
order: 2
layout: post
---

## Using the official Docker image in production

For quite some time, Portus has had an [official Docker image](https://hub.docker.com/r/opensuse/portus/tags/). This Docker
image has been built from [this](https://github.com/openSUSE/docker-containers/tree/master/derived_images/portus) repository. We encourage you to read the
[README.md file](https://github.com/openSUSE/docker-containers/blob/master/derived_images/portus/README.md) in order to understand:

- The tag policy.
- How to tune this image in order to use it for production.

Moreover, the [Portus repo](https://github.com/SUSE/Portus/tree/master/examples) contains examples using this Docker image in
production. We do not recommend a deployment method specifically, it is up to
you to decide which one fits better in your case. That being said, you are more
than welcome to share your deployment method in our [mailing list](https://groups.google.com/forum/#!forum/portus-dev).
