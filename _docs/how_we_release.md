---
layout: post
title: Portus Releases
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

1. Update the `VERSION` file.
2. Check whether the `CHANGELOG.md` file actually contains all the changes and
   that is not badly formatted.
3. Push a commit with the message "Bump version X.Y.Z"
4. Tag source code as X.Y.Z

With the steps above, we have released the new stable release in Github.
However, in SUSE we also make use of the
[Open Build Service](https://build.opensuse.org/). So, after releasing on
Github, we do the following on Open Build Service:

1. Create a project for X.Y.Z (e.g. `Virtualization:containters:Portus:Releases:X.Y.Z`).
2. Submit all the packages there from `Virtualization:containers:Portus`.
3. Edit the `Portus.spec` file and set Version to X.Y.Z and branch to X.Y.Z.
4. In the Portus package, change \_service to download source code with tag X.Y.Z.
5. Edit changes file with the contents of CHANGELOG.
6. In the Portus Appliance package, fix the repos to point to this release.
7. Wait for the packages to finish.
8. Submit to Factory.
