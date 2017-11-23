---
title: Rebumping portusctl
author: Miquel Sabaté Solà
layout: blogpost
---

Another [hackweek](https://en.opensuse.org/Portal:Hackweek), another new cool
project. At SUSE we are proud to get our hands dirty with hackweeks from time to
time. This is how [Portus was
born](https://flavio.castelli.me/2015/04/23/introducing-portus-a-user-interface-for-docker-registry/),
and how we've introduced some nice features like [security
scanning](/2017/07/19/security-scanning.html). This time, however, we wanted to
have some fun with one of our tools: **portusctl**.

## What is portusctl ?

The initial goal of `portusctl` was to make things easier for our openSUSE/SLE
users. This was done because in our RPM we had a clear picture on where things
were stored, how Portus was deployed, etc. Hence, we could automate most tasks
because we already knew what was needed to have a working Portus when installing
from an RPM.

This way, we introduced `portusctl` as a tool for our RPM users to achieve
exactly this, with commands like `setup`, `logs` and `exec`. Therefore, when
installing from an RPM, the instructions were clear:

- Install the provided RPM.
- Call `portusctl setup`.
- Magic happens.

There were quite some bugs on the process of making `portusctl`, but in the end
it worked and it proved to be quite useful.

## Why a new implementation was needed

Two things happened at once that made us re-evaluate the purpose of this tool:

1. The deployment of Portus had to be more focused on the containerized
   scenario. This is a trend that we have noticed both inside and outside of
   SUSE (e.g. [Portus as a Helm
   chart](https://github.com/kubic-project/caasp-services)). In this scenario, a
   tool like `portusctl` didn't matter that much (the most important commands
   are irrelevant there).
2. The community started to work on a REST API for Portus (thanks
   [@Vad1mo](https://github.com/Vad1mo) and
   [@andrew2net](https://github.com/andrew2net) for working on
   [#1299](https://github.com/SUSE/Portus/pull/1299) !). We quickly embraced
   this idea and started to move things to this new REST API. As of now, this
   API is not by any means in a stable phase, but it's mature enough so we can
   work with it more seriously.

While working on [SUSE CaaS
Platform](https://www.suse.com/products/caas-platform/), we started to
appreciate more and more one of the handier tools of Kubernetes:
[kubectl](https://kubernetes.io/docs/user-guide/kubectl/). This tool is, in
short, a client of the REST API of Kubernetes. It has a very nice user
experience, and we thought we could provide something similar for the Portus
API.

Our first move, then, was to check whether `portusctl` was a nice fit for it
(see [this pull request](https://github.com/SUSE/Portus/pull/1403)). The idea we
got from this proof of concept was that `portusctl` was a good candidate, but
adding this functionality would increase its maintenance burden. Having both the
old portusctl and this new big feature was not the best scenario, and following
the containerization trend, we decided that some of the old portusctl had to be
removed.

## The new portusctl

The [new portusctl](https://github.com/openSUSE/portusctl) is a tool that
interacts with the REST API very similar to Kubernetes' kubectl:

```bash
# Creating a user
$ portusctl create user username=admin email=admin@test.lan password=12341234

# Fetch namespaces
$ portusctl get namespaces

# Updating a user
$ portusctl update user 2 display_name=Administrator
```

Moreover, it can also interact with a local Portus instance with the `exec`
command:

```bash
$ portusctl exec rake portus:info
```

In order to implement all this, we started a new project under the openSUSE
umbrella named
[openSUSE/portusctl](https://github.com/openSUSE/portusctl). Since this new
`portusctl` was completely different from the old one, we implemented it from
scratch using Go, and we licensed it under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Conclusion

After re-evaluating `portusctl`, we decided to re-implement it from scratch so
it fits better how Portus is going to be deployed and used in the future. This
tool is not stable yet, but we have great confidence that this is the way to
go. Hopefully for the next version of Portus we can announce a proper stable
API, and `portusctl` as its stable client.

Keep tuned!
