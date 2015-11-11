---
layout: post
---

# Welcome to the Portus documentation!

On this page you can find information about:

{% for d in site.docs %}
- [{{ d.longtitle }}]({{ d.url }}).
{% endfor %}

## Quick start

Are you new to Portus and you have no idea how to start with it? Please, follow
this quick start guide. First of all, you need to install or deploy Portus. You
can do this in multiple ways:

- Setting it up for development purposes. This is the best way to mess with
Portus and getting to know it. Read more about this
[here](https://github.com/SUSE/Portus/wiki#developmentplayground-environments).
- Deploying Portus in production.

This guide will assume that you want to deploy Portus on production. In order
to do this, you have to first install it on your system. You can do this in
multiple ways, our favorites being:

- Installing Portus through the provided
[RPM](/docs/setups/1_rpm_packages.html).
- Using the ready to use [SUSE appliance](/docs/setups/2_appliance.html).

There are other alternative ways to install Portus, just check the `Setups`
section in the sidebar on the left for more information about them.

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

##### Thanks for your support!
