---
layout: default
title: Managing assets
longtitle: How assets are managed in production
order: 4
---

## Managing assets

In the [official image](https://hub.docker.com/r/opensuse/portus/) assets have
already been compiled. This means that they have already been compressed,
optimized, etc. This is done in the build process of the RPM that will be used
on the Docker image (check the
[%build](https://github.com/SUSE/Portus/blob/master/packaging/suse/portus.spec.in)
section for all the gory details).

So, the only thing missing is to serve the produced assets. You have two ways of
serving these assets: directly with *Rails*, or with a *load balancer*.

- If you set the `RAILS_SERVE_STATIC_FILES` to `true`, then Rails will serve the
  assets directly. This means that you won't need a load balancer in front of it
  to serve them
- If you have a *load balancer* in place, then you just need to serve the assets
  that are stored in `/srv/Portus/public`.

You can check examples of both deployments methods in the
[examples](https://github.com/SUSE/Portus/tree/master/examples) directory.
