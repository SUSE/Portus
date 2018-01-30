---
title: Configuring a secure private registry
layout: default
order: 2
longtitle: How to setup a secure private registry
---

## Creating the Registry

### Docker Distribution

The Docker Registry is a service that can talk to the docker daemon in order to
upload and download docker images. Since version 2, the docker registry is
called Distribution, and you can find the documentation
[here](https://www.docker.com/docker-registry).

There are multiple ways to deploy your own private registry. This page
[explains](https://docs.docker.com/registry/deploying/) how to do this. From a
deployment point of view, the only thing important for Portus is that it should
be reachable. Note that this will be checked when adding your registry into
Portus' database, as explained [here](/docs/Configuring-the-registry.html).

### Configuring the Registry in a safe way

Once you have your registry in place, you need to configure it. This can be
done either through the `/etc/registry/config.yml` file or through [environment
variables](https://github.com/docker/distribution/blob/master/docs/configuration.md#override-specific-configuration-options).
For convenience, we will assume that you have access to the `config.yml` file.
This is a config example:

{% highlight yaml %}
version: 0.1
loglevel: debug
storage:
  filesystem:
    rootdirectory: /var/lib/docker-registry
  delete:
    enabled: true
http:
  addr: :5000
  tls:
    certificate: /etc/nginx/ssl/my.registry.crt
    key: /etc/nginx/ssl/my.registry.key
auth:
  token:
    realm: https://my.portus/v2/token
    service: my.registry:5000
    issuer: my.portus
    rootcertbundle: /etc/nginx/ssl/my.registry.crt
notifications:
  endpoints:
    - name: portus
      url: https://my.portus/v2/webhooks/events
      timeout: 500ms
      threshold: 5
      backoff: 1s
{% endhighlight %}

Some things to note:

- The **loglevel** is set to `debug`. You usually want to relax this as specified
  [here](https://github.com/docker/distribution/blob/master/docs/configuration.md#log).
- The **storage** has been configured to be on the filesystem. This is a pretty
  basic and standard setup, but you can tweak it as much as you need. Just take a
  look at [this document](https://github.com/docker/distribution/blob/master/docs/configuration.md#storage)
  to learn all of the supported options. Also note that `deleted` has been set
  to `true`. Even if this is not a requirement from Portus' side, it might be
  in the future when removing images is supported.
- The **http** config is set to listen to the `:5000` port, which is the default
  value. Also note that in the `tls` configurable value we provide a
  certificate and a key. This will be used so the communication between the
  docker daemon and the registry is done through TLS. We *strongly* recommend
  to use this, otherwise we cannot guarantee that the communication will be
  secure. Both the key and the certificate will be generated automatically by
  `portusctl` if you are using the [RPM package](/docs/setups/1_rpm_packages.html).
- The **auth** value defines the communication between Portus and this
  registry. Some important things to note:
  - The **issuer** should be the same as the one defined by `machine_fqdn` in
    the `config/config.yml` file. This can be changed with the `PORTUS_MACHINE_FQDN`
    environment variable.
  - The **rootcertbundle** should point to the same location as the
    `encryption_private_key_path` configurable value as defined also in the
    `config/secrets.yml` file. This can be also tweaked with the `PORTUS_KEY_PATH`
    environment variable.
- The **notifications** configuration tells your registry where to send
  notifications. In this case, you should specify Portus' `/v2/webhooks/events`
  endpoint. This is used to synchronize the contents of the DB with the
  registry. You can read more about this
  [here](/features/1_Synchronizing-the-Registry-and-Portus.html).

## Integrating the Registry with Portus

From now on, we will suppose that a registry has already been created.

### How does Portus authorize requests ?

The next generation of Docker registries (those based on v2.0 or higher) push
the authorization of requests to an external authorization service. In our
case, this external authorization service will be Portus. If you would like to
have a more clear picture about this, take a look at this
[explanation](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md#docker-registry-v2-authentication-via-central-service)
from Docker's documentation.

When Portus receives an authorization request, it gets the following
information:

- The registry being targeted. Portus has to know the existence of the registry
  being targeted by the request. This is better explained in this
  [page](/docs/Configuring-the-registry.html).
- Who is trying to perform the action. The user must be known to Portus, and
  Portus will take into consideration whether the user is disabled, locked,
  etc. If everything is fine, then it will check basic authorization data like
  the password, etc.
- Which actions are trying to be performed.
- What is the target \<namespace\>/\<repo\>. Combining this with the given user
  and the given action, Portus decides whether the user is authorized to
  perform such action.

If Portus decides that the user is authorized to perform the action, then it
sends a JWT token suitable for the docker registry being targeted. You can read
all the details about the format of this JWT token
[here](https://github.com/docker/distribution/blob/master/docs/spec/auth/jwt.md).

### Configuring the JWT token sent by Portus

As stated in the previous section, the JWT token is used to handle the
authentication between Portus and your private registry. There are some
considerations in regards to this token.

First of all, it needs the `machine_fqdn` secret to be set. You can find this
in the `config/secrets.yml` file. If you change this file you should restart
Portus afterwards. Note that in production you can just provide the
`PORTUS_MACHINE_FQDN` environment variable.

Another thing to consider is the expiration time of the token itself. By default
it expires in 5 minutes. However, it's possible that the image to be uploaded is
too big or the communication is too slow; and the upload can take more than 5
minutes. If this happens, then the upload will be cancelled from the registry's
side, and it will fail. This is a known issue, and from Portus' side we provide
[this workaround](/docs/Configuring-Portus.html#advanced-registry-options).

### Synchronizing the Registry and Portus

As explained in [this](/features/1_Synchronizing-the-Registry-and-Portus.html)
page, Portus is able to synchronize the contents of the registry and its
database. In this regard, there are some considerations to be made.

First of all, note that no synchronization will be made until the admin sets up
the registry in Portus' database. This is better explained in this
[page](/docs/Configuring-the-registry.html).

Moreover, in order for this to happen, Portus needs the `portus` user to exist.
This user is created when setting up Portus for the first time by the admin.
This is done automatically by the `portusctl` tool if you are using the [provided
RPM](/docs/setups/1_rpm_packages.html) (or if you are on development mode and
you are using either the docker compose setup or the vagrant setup). If this is
not your case, you have to create it after migrating the database by performing:

    $ rake db:seed

or

    $ rake portus:create_api_account

Note that neither of these commands will work if you have not set the
`portus_password` secret value in the `config/secrets.yml` file. This value can
be set on production with the environment variable `PORTUS_PASSWORD`.

## Known issues

Since Docker Distribution 2.1, when Portus receives a web event regarding a tag
being pushed, it has to make another HTTP request in order to get which tag was
actually pushed. This works perfectly with either a development environment
without SSL or with a production environment with SSL with our provided
Passenger configuration. However, it's been reported that this does not work
properly in some setups. In these setups, the Rails worker tries to use the
same connection as the one used by the web event, and thus its gets stuck until
the web event times out. In order to work-around this, in this scenario you
need to setup your Rails instance so it uses more than one socket. An example
of this work-around can be found
[here](http://jordanhollinger.com/2011/12/19/deploying-with-thin/). If you want
to read more about this issue, you can find the original issue:
[Portus freezes when trying to get manifest after image push](https://github.com/SUSE/Portus/issues/373).
