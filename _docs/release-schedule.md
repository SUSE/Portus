---
layout: post
title: Release schedule
order: 8
longtitle: What to expect in future releases of Portus
---

## Release schedule for 2.2

### The dates

- Code freeze: January 10th 2017.
- Release candidate: January 16th 2017 (if no major issues have happened).
- Release: January 23th 2017 (if no major issues have been encountered).
- Patch-level releases will come as needed until a new major/minor release
  comes.

### What to expect

The 2.2 release is going to be a continuation of what the 2.1 release
delivered. Thus, this release will contain a couple of features that didn't make
it into the 2.1 release in time (e.g. namespace removal), and some improvements
to make Portus nicer to use for both users and administrators.

The complete list of features/improvements is listed in
[this milestone](https://github.com/SUSE/Portus/milestone/16). Some highlights:

- Provide a Docker image that can be used both in small deployments and in more
  complex scenarios. This is a long running issue that we'd like to finally get
  done during this release.
- Improve the experience for openSUSE/SLE users. That is, `portusctl` needs
  quite some improvements on the UI/UX front (e.g. handle upgrades smoothly).

Besides that, the list of features/improvements keeps on growing. We
will try to implement them if we have the time, but our priorities are the two
points mentioned above.
