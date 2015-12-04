---
layout: post
order: 4
title: Portus and the registry on the same FQDN using sub URI
---

## Big picture

It is possible to have both Portus and Docker registry running on the same host
using the same FQDN. Please **read the whole document** before trying to
implement this solution. The final result will look like this:

* Portus is going to be reachable by visiting: `https://docker.suse.con/portus`.
* Docker registry is going to be reachable at `docker.suse.con` on port 443.
* Communication with the Docker registry is going to be secured by SSL.

## Installation

These are the tools we are going to use:

* Portus.
* Docker registry.
* Apache2 as web server.
* [Phusion passenger](https://www.phusionpassenger.com/) to run Portus.

Everything can be installed via packages both on openSUSE and SUSE Linux
Enterprise. Follow [this](/docs/setups/1_rpm_packages.html) guide till the
end, just do not open Portus with your browser.

## Special configuration

We have to make some changes to the configuration produced by `portusctl`.

### Apache2

Create a new file `/etc/apache2/vhosts.d/portus_and_registry.conf`:

    <VirtualHost *:443>
       SSLEngine on
       SSLCertificateFile /etc/apache2/ssl.crt/docker.suse.con-ca.crt
       SSLCertificateKeyFile /srv/Portus/config/server.key

       RewriteEngine On

       RewriteCond %{REQUEST_URI} !^/portus.*$
       RewriteRule ^/(.*)$ "http:\/\/127\.0\.0\.1\:5000\/$1" [P,L]

       Alias /portus /srv/Portus/public
       <Location /portus>
         PassengerBaseURI /portus
         PassengerAppRoot /srv/Portus
       </Location>

       <Directory /srv/Portus/public>
          # This relaxes Apache security settings.
          AllowOverride all
          # MultiViews must be turned off.
          Options -MultiViews
          # Uncomment this if you're on Apache >= 2.4:
          Require all granted
          SetEnv GEM_PATH /srv/Portus/vendor/bundle/ruby/2.1.0
          SetEnv PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY 0
          SetEnv PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY 0
          PassengerAppEnv production
       </Directory>
    </VirtualHost>

This configuration will put Portus under the `/portus` sub-URI. At the same
time all the requests that are **not** starting with `/portus` are going to be
redirected to the Docker registry process. As you can see the Docker registry
is now listening on port 5000 of localhost. With this in mind:

- Note how both Portus and the Docker registry are served over HTTPS using the
same set of certificates.
- Make sure you remove the old Apache2 configuration file created by
`portusctl setup`; this should be named  `portus.conf`.
- Make sure you point apache to the right keys and certificates to use.

Enable the following Apache2 modules:

    $ a2enmod proxy
    $ a2enmod proxy_http
    $ a2enmod rewrite

Make sure you restart the apache2 process.

## Docker Registry

Edit `/etc/registry/config.yml` and make sure it looks like that:

{% highlight yaml %}
version: 0.1
loglevel: info
storage:
  filesystem:
    rootdirectory: /var/lib/docker-registry
  delete:
    enabled: true
http:
  addr: localhost:5000
  host: docker.suse.con

auth:
  token:
    realm: https://docker.suse.con/portus/v2/token
    service: docker.suse.con
    issuer: docker.suse.con
    rootcertbundle: /etc/registry/ssl.crt/portus.crt

notifications:
  endpoints:
    - name: portus
      url: https://docker.suse.con/portus/v2/webhooks/events
      timeout: 500ms
      threshold: 5
      backoff: 1s
{% endhighlight %}

As you can see the `tls` configuration has been dropped; this is no longer
needed because Apache2 is already encrypting all the network traffic. We also
changed all the urls referring to Portus. With this in mind:

- Make sure you change all the occurrences of `docker.suse.con` with your FQDN.
- Make sure you restart the registry process.

## Portus configuration

Now you can log into Portus and define which Docker registry should be used.
Pick up a name of your choice, use your FQDN (in that case would be
    "docker.suse.con") and toggle SSL usage.

## Have fun

Now you can push/pull images from "docker.suse.con". Portus can be accessed
by visiting "https://docker.suse.con/portus". Images can be tagged in this way:

* `docker.suse.con/busybox`
* `docker.suse.con/flavio/busybox`

## Issues

### Broken notifications

The configuration shown above works fine except for Docker registry
notifications. Portus receives the notifications from the registry, but
discards them because they are originated from "docker.suse.con:5000" instead
of "docker.suse.con". We think this is a bug of the Docker registry, we already
have a [patch](https://github.com/docker/distribution/pull/1142) for it.

In the meantime it's possible to have a workaround by doing some changes.

#### Portus

If you haven't defined the Docker registry to use just use the following data:

* hostname: 127.0.0.1:5000
* SSL: disable

Portus needs to talk with the Docker registry to gather additional information.
We will talk straight with the registry process listening on localhost. This
process does not have SSL turned on, remember this is done by Apache.

This is not a security issue. All the communication with the registry from your
docker clients is going to be handled by Apache (and hence encrypted). The
insecure communication is done only on localhost.

If you already have defined the Docker registry you need to change the contents
of your database. A quick way to do that is by using the Rails' interactive
console. Assuming you have installed Portus from the openSUSE/SUSE Linux
Enterprise packages you can do:

    $ portusctl exec rails c

    # now you are inside of Rails' console
    $ Registry.last.update(hostname: '127.0.0.1:5000', use_ssl: false)

#### Docker registry

Take the configuration show above and change the value for `service` under the `auth` section:

{% highlight yaml %}
auth:
  token:
    realm: https://docker.suse.con/portus/v2/token
    service: 127.0.0.1:5000
    issuer: docker.suse.con
    rootcertbundle: /etc/registry/ssl.crt/portus.crt
{% endhighlight %}

### Broken assets

Some of the Portus' assets are broken because they are served from `FQDN/` instead
of `FQDN/portus`. We are working to fix these issues, do not hesitate to file
bugs pointing to broken pages.
