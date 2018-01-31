---
title: How can I use and deploy Portus?
order: 3
anchor_link: how
---

<h4>Deploying in production</h4>

<p>
Since Portus is free software, you can deploy it in a wide variety of ways. That
being said, we mainly recommend two deployment procedures:
</p>

<ul>
<li>
<a href="/docs/setups/rpm.html"> The RPM package</a>: we maintain
<a href="https://build.opensuse.org/project/show/Virtualization:containers:Portus:2.0">a project in OBS</a>
in which we provide RPMs for openSUSE. This is perfect if you plan to deploy
Portus in a "traditional way". Moreover, the RPM includes some utilities like
<strong>portusctl</strong> which will help you on the installation and the
upgrade of Portus.
</li>
<li>
The <a href="https://github.com/openSUSE/docker-containers/tree/master/derived_images/portus">official Docker image</a>
maintained by us. This is the way to deploy Portus if you are interested on
using Docker, or one of the orchestration solutions that the community has to offer.
</li>
</ul>

<h4>Development</h4>

<p>
All the information related to development is written in our
<a href="https://github.com/SUSE/Portus/wiki">Github Wiki</a>. In there, you can
find some articles about this. In particular:
</p>

<ul>
<li>Using a <a href="https://github.com/SUSE/Portus/wiki/Vagrant-environment">Vagrant/VM</a> environment.</li>
<li>Our <a href="https://github.com/SUSE/Portus/wiki/Docker-Compose-Environment">Docker Compose</a> setup.</li>
<li>A <a href="https://github.com/SUSE/Portus/wiki/Bare-metal-development-environment">bare metal environment</a>.</li>
</ul>
