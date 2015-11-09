---
layout: post
title: Synchonizing the Registry and Portus
longtitle: Synchronization with your private registry in order to fetch which images and tags are available
---

## Webhooks

The most basic way in which Portus synchronizes the contents of the Registry
with its database is by listening the
[notifications](https://github.com/docker/distribution/blob/master/docs/notifications.md)
sent by the Registry itself. That is, on each push Portus will get a
notification from the Docker registry with all the information about the event.

This is convenient because this way the database can be updated on real time, when images and tags are actually pushed to the registry. One downside of this approach is that the database might become inconsistent over time. This can happen for example in this situation:

- The user pushes a new tag for an image.
- The Docker registry sends a notification, but in that very moment Portus was unreachable.
- Portus is reachable again, but it has missed the notification, therefore this new tag is not added to the database.

To fix this situation and others, we make use of the Catalog API that is provided by the registry itself, since the version 2.1.0 of the Docker registry. This is explained in the following section.

## The Catalog API

The Docker distribution project exposes a [Catalog API](https://github.com/docker/distribution/blob/master/docs/spec/api.md#listing-repositories) since version 2.1.0. By exposing this API, it's possible for Portus to check the consistency of the database with the registry. This is done in a job that periodically performs a synchronization operation.

This is done with the `crono` gem. In order to run this job periodically you should run the following command:

    $ bundle exec crono

Also note that this can come in handy if you are migrating an already existing registry to Portus, since it will sync everything from the registry to Portus automatically. This job is set to execute every 10 minutes, but this can be changed with the `CATALOG_CRON` environment variable. The value of this environment value has to be formatted as \<number\>.\<hours/minutes/seconds\>. For example: "2.minutes", "10.seconds", "1.hours". A customized example:

    $ RAILS_ENV=production CATALOG_CRON="2.minutes" bundle exec crono

Note though, that you should only do this if you are installing Portus manually. If you are using either the Vagrant/Docker setups or the appliance, you will not have to deal this. A [systemd service](https://github.com/SUSE/Portus/blob/master/packaging/suse/conf/portus_crono.service) file has been provided for this.

## Synchronizing clocks between the Registry and Portus

As pointed out by the issue [#9](https://github.com/SUSE/Portus/issues/9), if clocks are not synced between the private registry and Portus, problems may arise. This is because the token being generated in the authentication process has some attributes dealing with time (see the fields "nbf", "iat" and "exp" in the [specification](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md#requesting-a-token) for more info).

It's encouraged to use [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol) in order to prevent these issues from happening, since we cannot provide any fix inside of Portus itself.
