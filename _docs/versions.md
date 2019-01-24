---
layout: default
title: Supported Docker Versions
order: 6
longtitle: Which Docker versions are supported by Portus
---

## Docker and Docker Distribution

Docker technologies have a fast iteration pace. This is a good thing, but it
comes with some challenges. As requested by some of our users, the following
table shows which versions of Docker and Docker Distribution are supported by
each Portus version:

| Portus | Docker Engine | Docker Distribution | CoreOS Clair |
|:------:|:-------------:|:-------------------:|:------------:|
| master | 1.6+ | 2.0+ | 2.0.x |
| 2.4.2 | 1.6+ | 2.0+ | 2.0.x |
| 2.4.0 & 2.4.1 | 1.6+ | 2.0 to 2.6.x | 2.0.x |
| 2.3.x | 1.6+ | 2.0 to 2.6.x | 2.0.x |
| 2.1.x & 2.2.x | 1.6+ | 2.0 to 2.6.x | - |
| 2.0.0 & 2.0.1 | 1.6 to 1.9 | 2.0 to 2.2 | - |
| 2.0.2 | 1.6 to 1.9 | 2.0 to 2.4 | - |
| 2.0.3+ | 1.6+ | 2.0 to 2.4 | - |

Let's detail some of the versions being specified:

- Docker Engine `1.6` is the first version supported by Docker Distribution 2.
  Therefore, this requirement is also the same for Portus.
- As of Docker `1.10`, the Manifest Version 2, Schema 2 is the one being used.
  This is supported by Portus in `2.0.3` onwards.
- Docker Distribution `2.3` supports both Manifest versions, but some changes
  had to be made in order to offer backwards compatibility. This is not
  supported neither for Portus `2.0.0` nor `2.0.1`.
- Docker Distribution `2.7` changed the semantics around the `delete`
  action. This is supported in `2.4.2+` and in the `master` branch of Portus.
- CoreOS Clair has been supported as a security scanner since `2.3.0`.
