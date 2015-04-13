Portus: a user interface for the [next generation of Docker registry](https://github.com/docker/distribution).

Portus targets [version 2](https://github.com/docker/distribution/blob/master/docs/spec/api.md)
of the Docker registry API. It aims to act both as
an authoritzation server and as a user interface for the next generation of the
Docker registry.

## Specs


### Authentication

Portus implements the [token based authentication system](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md)
described by the new ersion of the Docker registry.

[This](https://gitlab.suse.de/docker/portus/wikis/authentication-process) page
contains more details about the ongoing efforts to implement authentication.

### Notifications

The registry can be configured to notify a 3rd party about the events that took
place (eg: push, pull,...).

This is described by [this](https://github.com/docker/distribution/blob/master/docs/notifications.md).

Portus can takes advantage of this feature to be aware of all the Docker images
pushed to the registry.

## Development environment

This project contains a Vagrant based development environment which consists of
three nodes:

  * `registry.test.lan`: this is the node running the next generation of the
    Docker registry.
  * `portus`: this is the node running portus itself.
  * `client`: a node where latest version of Docker is installed

All the nodes are based on openSUSE 13.2 x86_64. VirtualBox is the chosen
provisioner.


### Sinatra POF

There's a really stupid sinatra app that can be used to fake the new UI.

To play with it:

```
vagrant ssh portus
sudo gem install sinatra shotgun
shotgun.ruby2.1 -p 5000 /vagrant/app.rb
```

### Intercepting all the traffic sent to the registry

On the client node execute:

```
docker run -ti --rm --add-host=registry.test.lan:192.168.1.2 -p 5000:5000 jess/mitmproxy -p 5000 -R http://registry.test.lan:5000
```

Now on the client node do:

```
docker tag busybox localhost:5000/busybox
docker push localhost:5000/busybox
```
