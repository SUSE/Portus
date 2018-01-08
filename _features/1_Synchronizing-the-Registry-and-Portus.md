---
layout: post
title: Synchonizing the Registry and Portus
longtitle: Synchronization with your private registry in order to fetch which images and tags are available
order: 1
---

## Webhooks

The most basic way in which Portus synchronizes the contents of the Registry
with its database is by listening the
[notifications](https://docs.docker.com/registry/notifications/) sent by the
Registry itself. That is, on each push Portus will get a notification from the
Docker registry with all the information about the event.

This is convenient because this way the database can be updated on real time,
when images and tags are actually pushed to the registry. One downside of this
approach is that the database might become inconsistent over time. This can
happen for example in this situation:

- The user pushes a new tag for an image.
- The Docker registry sends a notification, but in that very moment Portus was
  unreachable.
- Portus is reachable again, but it has missed the notification, therefore this
  new tag is not added to the database.

To fix this situation and others, we make use of the Catalog API that is
provided by the registry itself, since the version 2.1.0 of the Docker
registry. This is explained in the following section.

## The Catalog API

The Docker distribution project exposes a [Catalog
API](https://github.com/docker/distribution/blob/master/docs/spec/api.md#listing-repositories)
since version 2.1.0. By exposing this API, it's possible for Portus to check the
consistency of the database with the registry.

This is one of the main tasks of the [background process](/docs/background) that
should be running on any production-ready deployment. This process will
continuously check for the consistency of the DB against the registry, and
update the DB when needed.

**Note**: before the 2.3 release this was done by another process called
*crono*. For users coming from previous releases, you should know that this
crono process has been integrated into this new process called background (which
is capable of performing other tasks as well).

## Synchronizing clocks between the Registry and Portus

As pointed out by the issue [#9](https://github.com/SUSE/Portus/issues/9), if clocks are not synced between the private registry and Portus, problems may arise. This is because the token being generated in the authentication process has some attributes dealing with time (see the fields "nbf", "iat" and "exp" in the [specification](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md#requesting-a-token) for more info).

It's encouraged to use [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol) in order to prevent these issues from happening, since we cannot provide any fix inside of Portus itself.
