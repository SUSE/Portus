---
layout: post
title: Supported Docker Versions
order: 6
longtitle: Which Docker versions are supported by Portus
---

## Docker and Docker Distribution

Docker technologies have a fast iteration pace. This is a good thing, but it
comes with some challenges. As requested by some of our users, the following
table shows which versions of Docker and Docker Distribution are supported by
each Portus version:

| Portus | Docker Engine | Docker Distribution |
|:------:|:-------------:|:-------------------:|
| master | 1.6+ | 2.0+ (2.4+ recommended) |
| 2.1.0 | 1.6+ | 2.0+ (2.4+ recommended) |
| 2.0.0 & 2.0.1 | 1.6 to 1.9 | 2.0 to 2.2 |
| 2.0.2 | 1.6 to 1.9 | 2.0+ |
| 2.0.3+ | 1.6+ | 2.0+ |

Let's detail some of the versions being specified:

- Docker Engine `1.6` is the first version supported by Docker Distribution 2.
  Therefore, this requirement is also the same for Portus.
- As of Docker `1.10`, the Manifest Version 2, Schema 2 is the one being used.
  This is only supported by Portus in the `master` branch and in `2.0.3`.
- Docker Distribution `2.3` supports both Manifest versions, but some changes
  had to be made in order to offer backwards compatibility. This is not
  supported neither for Portus `2.0.0` nor `2.0.1`. Moreover, Docker
  Distribution `2.4` was the first to introduce garbage collection. Because of
  this, we recommend running Docker Distribution version `2.4` (or higher) if
  you are using Portus version `2.1` or later.

## Docker Compose

<div class="alert alert-info">
  Only for <strong>development</strong> purposes.
</div>

In our Docker Compose development setup described
[here](https://github.com/SUSE/Portus/wiki/Docker-Compose-Environment), we
require Docker Compose 1.6 or later. You might want to setup a Docker
Compose setup differently, but we recommend sticking to using the
`compose-setup.sh` script.
