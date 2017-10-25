---
title: Portus - Documentation
layout: post
---

# Welcome to the Portus documentation!

On this page you can find information about:

{% assign docs = site.docs | sort: 'order' %}
{% for d in docs %}
- [{{ d.longtitle }}]({{ d.url }}).
{% endfor %}

## Quick start

Are you new to Portus and you have no idea how to start with it? Please, follow
this quick start guide.

First of all, if you are only interested in knowing how you can *login* and *push*
images to a registry which has Portus as an authorization service, you might be
interested in reading [this page for newcomers](/docs/first-steps.html).
Otherwise, if you need to install or deploy Portus, you can do it in two ways:

- Set it up for development purposes. This is the best way to mess with
Portus and getting to know it. Read more about this
[here](https://github.com/SUSE/Portus/wiki#developmentplayground-environments).
- Deploy Portus in production.

This guide will assume that you want to deploy Portus on production. There are
multiple ways of achieving this, the recommended ones being the [RPM](/docs/setups/1_rpm_packages.html) setup and
the [containerized](/docs/setups/2_containerized.html) solutions. There are other alternative ways to install
Portus, as you can see in the `Setups` section in the sidebar on the left.

Now, before you jump into trying to use Portus in your browser, there are
some configuration steps that you should follow. This is thoroughly explained
in [this document](/docs/Configuring-Portus.html). After configuring Portus to
your liking, restart your HTTP server and open Portus in your browser. You are
required to tell Portus where your registry is located. In order to do so,
please follow [this page](/docs/Configuring-the-registry.html).

At this point, you should be able to enjoy Portus. Now you might want to read
all the [features](/features.html) that Portus provides. We hope that you like
it!

## Contributing

Please feel free to create issues [here](https://github.com/SUSE/Portus) if
you would like to request more material to be created for the Portus
documentation. If you want to contribute directly to this documentation page,
you might want to open up a new pull request against the
[gh-pages](https://github.com/SUSE/Portus/tree/gh-pages) branch.

For any other doubt that you may have regarding our documentation or anything
about Portus in general, feel free to say something in our [mailing
list](https://groups.google.com/forum/#!forum/portus-dev).

##### Thanks for your support!
