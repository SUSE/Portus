---
layout: post
title: Portus Releases
order: 4
longtitle: How we release Portus
---

## Brief explanation

The release procedure is quite straightforward and simple. Once a release has
been done, the team meets to plan which features has to be implemented for the
next version. Once we agree on this, we set a more or less fixed date in which
we should release the next stable version. Once we are around said date, we
will release the next version whenever we feel that Portus is ready (while
taking into account other stuff like documentation, etc.).

## The procedure

First of all, we follow this steps on the Github repository:

1. Create a new branch name `vX.Y`, being X.Y the new version.
2. For a small period of time, this branch will receive last-time
   updates/fixes, like for example reviewing the gems in the Gemfile.lock.
3. Update the `VERSION` file (in that branch).
4. Check whether the `CHANGELOG.md` file actually contains all the changes
   and that is not badly formatted.
5. Push a commit with the message "Bump version X.Y.Z".
6. Tag source code as X.Y.Z.

With the steps above, we have released the new stable release on Github.
However, in SUSE we also make use of the [Open Build
Service](https://build.opensuse.org/). The containers team at SUSE usually works
in the
[Virtualization:containers](https://build.opensuse.org/project/show/Virtualization:containers)
project, but for Portus we decided to work on three different subprojects:

- [Virtualization:containers:Portus](https://build.opensuse.org/project/show/Virtualization:containers:Portus), which contains an RPM with the latest commit on the `master` branch.
- [Virtualization:containers:Portus:2.0](https://build.opensuse.org/project/show/Virtualization:containers:Portus:2.0), containing the latest stable release (2.0).
- [Virtualization:containers:Portus:2.0-git](https://build.opensuse.org/project/show/Virtualization:containers:Portus:2.0-git), containing the latest commit on the stable branch (v2.0).

New minor and major releases will have their own subproject, which will follow the
same rationale as for the ones that we have for the 2.0 release. Also note that
the RPMs produced by these three different projects are the ones that will also
be used in the [official Docker images](https://hub.docker.com/r/opensuse/portus/).
You can find more information about these pages
[here](https://github.com/openSUSE/docker-containers/tree/master/derived_images/portus).

## Scripts

To handle the release process as it has been described, we use some custom
scripts and rake tasks. In particular, the rake tasks are `release:prepare`
and `release:bump`. The other scripts being used can be found
[here](https://github.com/SUSE/Portus/tree/master/packaging/suse/release).
