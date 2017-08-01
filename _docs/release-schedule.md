---
layout: post
title: Release schedule
order: 8
longtitle: What to expect in future releases of Portus
---

## Release schedule for 2.3

The 2.3 release will be mostly about fixing known bugs and testing. This release
will also improve the documentation on how to deploy and use Portus in
production, while taking special care of the official Docker image. This has
already been done (see [this PR](https://github.com/SUSE/Portus/pull/1254)), but
we will improve the situation even further until the final release.

Besides all this, this release will also bring some new features, but let's take
a look at the calendar first:

- October will have a code freeze, so no new features are allowed to be merged
  afterwards.
- On November 8th, the first release candidate will be released.
- From then on, new release candidates will be released every two weeks until we
  feel the final release is ready to be tagged.

With this in mind, the exact number of features to be included is not set in
stone, but the only requirement is that they make it before the code freeze on
October. For now we have already written some exciting features such as:

- The [announced security scanning support](/2017/07/19/security-scanning.html),
  in which Portus will be able to show the vulnerabilities that were found in
  your Docker images. Check
  the [pull request](https://github.com/SUSE/Portus/pull/1289) if you want to
  read all the gory inner details.
- We are now using Puma for the official Docker image (see
  the [PR](https://github.com/openSUSE/docker-containers/pull/47)).

But we have some handy new features in the pipeline that will be pretty
interesting too. Stay tuned!
