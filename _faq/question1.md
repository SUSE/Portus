---
title: Why use Portus?
order: 2
---

<p>
When we started this project, we already had some images on the Docker Hub, and
we enjoyed using it. That being said, soon enough we realized the problems that
Docker Hub entails:
</p>

<ul>
<li>You have to trust another entity to store and manage your Docker images.</li>
<li>A centralized hub for all your images is not always a viable option. What if Docker Hub goes down?</li>
<li>As a user, you should be able to escape vendor lock-in.</li>
</ul>

<p>
Fortunately for us, Docker has a project called <a href="https://github.com/docker/distribution">Distribution</a>
that addressed one of our biggest concerns: being able to deploy an on-premise
Docker registry that takes care of storing and distributing your private Docker
images.
</p>

<p>
Docker Distribution was designed with the UNIX principle in mind of "do one
thing and do it well". For this reason, Distribution only takes care of storing
and distributing your images, and offers an API so services can be built on top
of it. There are two main aspects of said API:
</p>

<ul>
<li>An authorization procedure that works with Docker.</li>
<li>The ability to fetch the catalog of images and modify it.</li>
</ul>

<p>
With this in mind, we started Portus to address all of our concerns in regards
to distributing images inside of an organization, while providing a clear user
interface. Moreover, we released Portus as free software. We did that because:
</p>

<ul>
<li>We didn't want to put the pressure of vendor lock-in to our users.</li>
<li>We wanted to contribute back to the community around container technologies.</li>
</ul>
