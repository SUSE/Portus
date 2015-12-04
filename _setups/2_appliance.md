---
layout: post
order: 2
title: openSUSE Appliance
---

## Import/Download

In order to make it easier to test Portus, we have created an appliance which
you can start in an [openStack](https://www.openstack.org/) cloud or locally
with the virtualization solution that you like.

In order to start it in an [openStack](https://www.openstack.org/) cloud, you
can import the [1.0.1 image](http://download.opensuse.org/repositories/Virtualization:/containers:/Portus:/Release:/1.0.1/images/PortusAppliance.x86_64.qcow2).
If you want to start this appliance locally, download the
[1.0.1 image appliance](http://download.opensuse.org/repositories/Virtualization:/containers:/Portus:/Release:/1.0.1/images/PortusAppliance.x86_64.qcow2),
which is on a qcow2 format. You can use this format with
[qemu-kvm](http://wiki.qemu.org/KVM) or you can convert this format to any
that you need by using [qemu-img convert](http://linux.die.net/man/1/qemu-img).

If you want to play with the development image, you can get it from
[here](http://download.opensuse.org/repositories/Virtualization:/containers:/Portus/images/PortusAppliance.x86_64.qcow2).
Feel free to contribute to the appliance by
[branching it](https://build.opensuse.org/package/branch_dialog/Virtualization:containers:Portus/PortusAppliance)
on the [openSUSE Build Service](http://build.opensuse.org).

## Firstboot

This appliance has a firstboot configuration for the root password and the
hostname. This will appear on your console, so make sure to look into that.
Until you have finished the first boot configuration, no network will be
available, thus you won't be able to ssh into your appliance. Make sure that
the hostname you choose is resolvable (if it is a test hostname, add it to your /etc/hosts).

![hostname configuration](/build/images/docs/portus1stboot.png)

![root password setup](/build/images/docs/portus1stboot_2.png)

## Connect

You can connect now to your appliance on `http://_hostname_` (being
`_hostname_` the one you've configured in firstboot) and follow the
instructions you'll find there.

If you want to connect with ssh, you can only do that with a keypair, which,
if you are running it in an openstack cloud, you would have configured when
launching the instance. If you are not running it on a cloud, you most
probably won't have had your ssh keypair injected, and you can only connect
by using the console with the password you had set up at firstboot.

## Portus over https, Distribution with tls enabled

For security reasons you should use an encrypted channel. This means securing
portus over https and docker distribution with tls. Ideally you would have a
key, a certificate and a certificate authority. If you don't, you can create
your own by running:

    $ gensslcert -C "$HOSTNAME" -o "SUSE Linux GmbH" -u "SUSE Portus example" -n "$HOSTNAME" -e kontakt-de@novell.com -c DE -l Nuremberg -s Bayern

This will create a self signed certificate, which, even though is not useful
for authenticating, it is for encrypting.

## Portus over https

### Apache with SSL

First of all you need to configure `apache2` to use HTTPS. Adapt the
`/etc/apache2/vhosts/ssl.template` file to your host configuration. Make sure
you have your key at `/etc/apache2/ssl.key/` and the server certificate and
the ca certificate at `/etc/apache2/ssl.crt/`.

Then you have to enable SSL on your apache2 configuration. In order to do
that, make sure that the `/etc/apache2/listen.conf` file is set to listen to
the 443 port and enable the module with `a2enmod ssl`.

### Comunication between Portus and registry with SSL

Once you have apache2 SSL configuration enabled, you need to make sure that the
user running apache2 can access the key. This is needed in order to use the
same certificate for Portus.

After that, edit the `config/secrets.yml` file and set the path to the key at
the `encryption_private_key_path` variable. With this, Portus can now encrypt
the messages.

The next step is to make the registry be able to verify those messages. In
order to do that, edit the `/etc/registry/config.yml` file to use the
`rootcertbundle`, and also to use HTTPS Something like:

{% highlight yaml %}
auth:
  token:
    realm: https://__HOSTNAME__/v2/token
    service: __HOSTNAME__:5000
    issuer: __HOSTNAME__
    rootcertbundle: /etc/registry/ssl.crt/portus.crt
{% endhighlight %}

And finally, add the `CA.crt` to the system by copying the
`/etc/apache2/ssl.crt/$HOSTNAME-ca.crt` into
`/etc/pki/trust/anchors/_ and running _update-ca-certificates` (assuming you
are running on SUSE).

## Distribution with TLS for communicating with Docker client

The second part of securing your installation is to set up distribution to use
TLS for communicating with the Docker client. In order to do that, edit the
`/etc/registry/config.yml` file and add something like:

{% highlight yaml %}
http:
  addr: :5000
  tls:
    certificate: /etc/registry/ssl.crt/portus.crt
    key: /srv/Portus/config/server.key
{% endhighlight %}

This sets the Registry to use TLS over HTTP on port 5000. Make sure the cert
and key files are those set up for apache2 (for simplicity we use only one
certificate).

The last and final step is to add the `CA.crt` file to the clients machine.
Just like we did in the previous section, and if you are running the client
on a different machine, import the `CA.crt` to the system by copying the
`/etc/apache2/ssl.crt/$HOSTNAME-ca.crt` into `/etc/pki/trust/anchors/` and
running `update-ca-certificates` (assuming you are running on SUSE).

It may seem a little tedious but it is the way to make sure your installation
is secured. If you don't want to do the setup, just download
[the appliance](/docs/setups/2_appliance.html#importdownload), where we have
set up all of that for you.

## Known issues

Since Docker Distribution 2.1, when Portus receives a web event regarding a tag
being pushed, it has to make another HTTP request in order to get which tag was
actually pushed. This works perfectly with either a development environment
without SSL or with a production environment with SSL with our provided Passenger
configuration. However, it's been reported that this does not work properly in
some setups. In these setups, the Rails worker tries to use the same connection
as the one used by the web event, and thus its gets stuck until the web event
times out. In order to work-around this, in this scenario you need to setup
your Rails instance so it uses more than one socket. An example of this
work-around can be found [here](http://jordanhollinger.com/2011/12/19/deploying-with-thin/).
If you want to read more about this issue, you can find the original
issue: [Portus freezes when trying to get manifest after image push](https://github.com/SUSE/Portus/issues/373).

## Configuring the Portus instance

Before you start using Portus, you have to configure it. This is thoroughly
explained [here](/docs/Configuring-Portus.html). In
the configuration, make sure to check:

- The configuration for LDAP support. (Read more [here](/docs/Configuring-Portus.html#ldap-support))
- How to create the first admin user. (Read more [here](/docs/Configuring-Portus.html#creating-the-first-admin-user))
- Enforce SSL on production. (Read more [here](/docs/Configuring-Portus.html#enforce-ssl-usage-on-production))
