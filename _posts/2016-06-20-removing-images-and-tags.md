---
title: Removing images and tags
author: Miquel Sabaté Solà
layout: blogpost
---

Hello again!

Some months ago we implemented one of the most requested features for Portus:
removing images and tags. This is one of the most important features that will
be available on the 2.1 release (due in September), and it has been a bit
challenging to get it right.

The main original blocker for this feature is that Docker Distribution only
provides garbage collection as of its 2.4 version. This is important because
we didn't feel save releasing this feature without proper support from
the registry's side. With this in mind, we are sure that lots of users are
still not running on Docker Distribution 2.4 (and probably won't for quite some
time) so, to avoid any surprises we have disabled this feature by default. That
is, in order to remove images and tags from within Portus, administrators will
have to conciously enable it. You can do this with the
[delete](/docs/Configuring-Portus.html#delete-support) configurable value.

Last but not least, it's important to note that maintainers are the ones
responsible for running the garbage collector (it's not done automatically by
the registry and it cannot be activated through an API endpoint). Therefore,
it's up to administrators to decide what they want to do. For more information
on this, please take a look at both
[our documentation](/features/removing_images.html) and the one from
[Docker Distribution](https://github.com/mssola/distribution/blob/master/docs/garbage-collection.md).

With this feature already on our belt, we will be able to proceed with more
features that will make it for the 2.1 release, like removing namespaces or
users. If you are interested in knowing more about this, just say something on
our [Google group](https://groups.google.com/forum/#!forum/portus-dev) or
submit a new issue on our [Github project](https://github.com/SUSE/Portus).

Enjoy!
