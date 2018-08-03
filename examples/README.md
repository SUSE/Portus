# Deploying Portus

## Important note

These examples are distributed and maintained in the hope that they will be
useful, but without any warranty. We do *not* claim that these examples are
bug-free or 100% secure. It's up to you to decide how to use them, and we expect
you to review these files so they fit your purposes before doing anything with
them.

Moreover, we also tried to show as many different ways of deploying Portus as
possible. This ranges from using certain environment variables which might not
fit your use case, or features like static volumes that might not be strictly
needed or useful to you. Hence, we recommend to all of those willing to use
these files to first try them, tune them, and review them carefully.

All that being said, enhancements are always welcomed.

## What is this?

In this directory we've compiled the files of different deployment
strategies. All these examples are based on the [official Portus
image](https://hub.docker.com/r/opensuse/portus/), and they only work for Portus
2.3 and later. Support for older versions is not possible without creating new
directories and configuration files.

For now we have:

- An example that uses `docker-compose`. This is a good way to setup a
  production-ready Portus deployment within a single host. It's also a minimal
  example that only requires docker and docker-compose in order to
  work. Moreover, this same example could be extended to make it work in
  multiple hosts through Docker Swarm.
- An orchestrated example that uses `Kubernetes`. This example will allow you to
  deploy a production-ready Portus deployment on top of an existing Kubernetes
  cluster. Note that we assume that you already have a *working* and reliable
  Kubernetes cluster (setting up a Kubernetes cluster is beyond the scope of
  this project: please refer to the Kubernetes documentation for this).

## Other deployments

The community has been nice enough to provide us with multiple deployment
examples. Some of these examples have helped us mature our own official image,
so we equally encourage you to take a look at them if you want to get a better
grasp of how to deploy Portus. These other examples are:

- A configureable build of Portus for production used and rancher catalogs
  by [@EugenMayer](https://github.com/EugenMayer). Check it out
  [here](https://github.com/EugenMayer/docker-image-portus).
- A setup that runs on Oracle Linux 7 and that uses NGinx to proxy between
  Portus and the registry by [@Djelibeybi](https://github.com/Djelibeybi/). Check
  it out [here](https://github.com/Djelibeybi/Portus-On-OracleLinux7).
- A lightweight setup by [@h0tbird](https://github.com/h0tbird) that uses Alpine
  underneath. You can check it out [here](https://github.com/katosys/portus).

If you have an example of your own, and you think it can be useful to other
people, submit a PR including yours in here!
