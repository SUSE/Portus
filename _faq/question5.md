---
title: I have problems with SSL
order: 4
anchor_link: ssl
---

<p>
One of the most common problems when deploying Portus is failing at configuring
SSL. We are sure that, at this point, if you are having problems with SSL it is
not because of a bug in either Portus or the Docker registry, but rather:
</p>

<ul>
<li>
You are missing something on how Portus has to be setup in order for it to use
SSL. Check out <a href="/docs/How-to-setup-secure-registry.html">this page</a>
on the documentation for more info.
</li>

<li>
Your setup is malfunctioning. You are using your own setup and there is a piece
of it that is not working fine, or the communication between the processes you
are using is broken. For this, check out the setups that we describe in the
<a href="http://port.us.org/documentation.html">documentation</a>, or check out
our <a href="https://groups.google.com/forum/#!forum/portus-dev">Google group</a>
or the <a href="https://github.com/SUSE/Portus/issues">reported issues</a>
for some hints. It's possible that someone else is using a setup that is
similar to yours and therefore reading the discussion might help you.
</li>
</ul>
