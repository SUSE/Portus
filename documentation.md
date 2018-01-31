---
title: Portus - Documentation
layout: default
---

# Welcome to the Portus documentation!

On this page you can find information about:

{% assign docs = site.docs | sort: 'order' %}
{% for d in docs %}
- [{{ d.longtitle }}]({{ d.url }}).
{% endfor %}

## Quick start

First of all, if you are only interested in knowing how you can *login* and
*push* images to a registry which has Portus as an authorization service, you
might be interested in reading [this page for
newcomers](/docs/first-steps.html).  Otherwise, if you need to install or deploy
Portus, you can do it in two ways:

- Set it up for development purposes. This is the best way to mess with
Portus and getting to know it. Read more about this
[here](https://github.com/SUSE/Portus/wiki#developmentplayground-environments).
- [Deploy Portus](/docs/deploy.html) in production.

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
