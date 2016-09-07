---
layout: post
title: Docker and Portus for newcomers
order: 0
longtitle: The first steps into using Docker and your registry
---

<div class="alert alert-info">
  This page is targetted towards newcomers to the Docker ecosystem that want
  to get acquainted with commands such as <strong>login</strong> or
  <strong>push</strong>. If this is not your case, feel free to skip this page.
</div>

# Basic definitions

## The Docker Engine

The Docker Engine (or just "Docker" as most people refer to it) is a CLI tool
that allows you to run your applications in a controlled, secure and portable
environment. As a starting point, you can think of Docker *containers* as
something similar to virtual machines but with a radically different
architectural approach that makes them much more efficient and portable.

Starting with Docker will introduce you to lots of different concepts like
*images* and *containers*. You need to learn all these concepts (or at least
have a basic idea about them) before you proceed with this page (or any page
on Portus). Docker provides
[great documentation](https://www.docker.com/what-docker) for newcomers, so make
sure to read it and come back for more information.

## Docker Distribution and Portus

Docker Distribution (also known as **Docker Registry**) is a storage and
distribution solution for your Docker images. It is the backend behind the
[Docker Hub](https://hub.docker.com/) and it's [open
source](https://github.com/docker/distribution). The fact that it is open source
means that you can have your own Docker Registry on your own servers. This is
really interesting for lots of different reasons, but one main thing to
consider is that it delegates authorization to an "authorization service".

As explained [here](/docs/How-to-setup-secure-registry.html) one of the main
jobs of Portus is being an authorization service for your Docker registry. The
other main goal of Portus is to provide a useful and powerful UI on top of your
registry. You can learn about all this [here](/features.html).

# Interacting with a registry and Portus in the CLI

## Log in and out

First and foremost, you have to make sure that you have an account already
available in your Portus instance. Usually you create the account yourself by
going to the "Signup" page. This might not be the case if:

- Your organization is using an [LDAP server](/features/2_LDAP-support.html)
  for authentication, in which case you just need to login at least once with
  your LDAP credentials into Portus.
- Your organization has
  [disabled the sign up form](/features/disabling_signup.html). In this case
  the administrators of Portus have to tell you what your credentials are.

Once you are sure that you have your Portus user in place, you need to login
to your registry with the `docker login` command. Assuming that your
registry's hostname is `https://my.registry:5000`, then you should perform the
following in a terminal:

    $ docker login my.registry:5000

The previous command will ask for your credentials and, if everything goes as
expected, you will successfully login to your registry. Note two things:

1. If you don't specify a hostname, then Docker assumes the
   [Docker Hub](https://hub.docker.com/).
2. You don't have to specify the `https://` part.

After logging in your credentials will be stored in your system so you won't
have to login again unless you explicitly log out with the `docker logout`
command. Note that in the `logout` command you will also have to pass the
hostname (or Docker will assume Docker Hub).

## Push & pull

The Docker Engine will allow you to push or pull only if you are logged in. If
this is the case, then it will be up to the authorization service (Portus in
our case) to decide whether you can push or pull. This depends on which team
your user belongs to, which role he or she plays in said team and so on. Check
out [this page](/features/3_teams_namespaces_and_users.html) for more
information on the topic.

Assuming that your user is called `mssola`, you can be sure that a namespace
with the exact same name exists (unless the given user name does not abide to
[Docker's naming rules](https://github.com/docker/docker/blob/master/docs/reference/commandline/tag.md).
In this case, the name of the namespace will be transformed and the user will
get notified about this change). This is because each user has a
**personal namespace**. In there, you will always be able to push and pull. We
will use this as an example because of its simplicity.

Let's say that you want to push a local image called `image:latest` to your
registry. The first thing that comes to our mind is to perform the following
*wrong* command:

    $ docker push image:latest

This is wrong because Docker will assume that your image should be pushed onto
the Docker Hub. In order to avoid this you have to specify the hostname of your
registry in the name of the image that you want to push. In order to
accomplish this, we will use the `docker tag` command:

    $ docker tag image:latest my.registry:5000/mssola/image:latest

Note two things in the previous command:

1. The `https://` part is not specified.
2. We also added `mssola` to it. We did this to specify that the `image:latest`
   image should be stored inside of the `mssola` namespace, which is your
   personal namespace. If you don't provide this, then Portus will assume that
   you want to push this image into the **global namespace**, which is only
   writeable by administrators. You can read more about this
   [here](/features/3_teams_namespaces_and_users.html).

Now you can push it:

    $ docker push my.registry:5000/mssola/image:latest

If everything goes as expected, your image should have been pushed into your
registry! Now, whenever you want to pull this image again, just perform the
following command:

    $ docker pull my.registry:5000/mssola/image:latest

# Next steps

If you are also an administrator make sure to understand all the nuts and
bolts regarding deploying and configuring Portus. In order to do this, just go
to the [documentation page](/documentation.html). Another interesting page is
the [features](/features.html) page, in which you will learn about the
capabilities that Portus has to offer.

Otherwise, if you have any doubt that the documentation fails to cover, don't be
shy and ask in our [Google group](https://groups.google.com/forum/#!forum/portus-dev).
We are eager to understand what we can do to improve your experience with
Portus!
