# Portus on Docker compose

This example is two-folded, as it contains the same example deployed in two
ways:

- A production-ready setup where all communication is encrypted.
- A version which doesn't use encryption for simplicity.

As explained in the [README file](../README.md) above, this example uses the
[official Portus image](https://hub.docker.com/r/opensuse/portus/), so it has
nothing to do with the docker-compose setup used for development in the root
directory.

## The hostname

This example needs the hostname in multiple places. All this has been delegated
into Compose's support of the `.env` file. For this reason, you will need to
change hostname set in this file, and also in the `nginx/nginx.conf` file.

## Certificates

This example is set up in a way so you can use self-signed certificates. Of
course this is not something you would want to do in production, but this way we
ease up the task for those who are curious to try it out.
In order to create self-signed certificates, you could use the following command:

```bash
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout portus.key -out portus.crt
```

After that, you can simply move the ``portus.key`` and the ``portus.crt`` files
into the secrets directory.

## The setup

### Secure example

The secure example uses an NGinx container that proxies between the Portus and
the Registry containers. Communication is always encrypted, but note that this
is not strictly necessary. Because of this proxy setup, both Portus and the
registry end up using the same hostname. Practically speaking:

- When setting up the registry for the first time in Portus, you have to check
  the "Use SSL" box and enter the hostname without specifying any ports.
- From the CLI, docker images should be prefixed with the hostname, but without
  specifying any ports (e.g. "my.hostname.com/opensuse/amd64:latest")

Again, as advertised [here](../README.md), take the word "secure" with a grain
of salt. Do *not* deploy these files blindly into your cluster: review them
first, and make all the changes you need to fit your purpose.

### Insecure example

The other example is as minimal as possible. Because of this, there's no NGinx
proxy and the Portus and the Registry containers are bound to their respective
ports. Moreover, SSL has not been configured on this setup. Because of this:

- When setting up the registry for the first time in Portus, you do **not** have
  to check the "Use SSL" box. Moreover, the hostname has to end with the 5000 port
  (e.g. "my.hostname.com:5000").
- From the CLI, docker images should be prefixed with the hostname and the 5000
  port (e.g. "my.hostname.com:5000/opensuse/amd64:latest")

### Serving static assets

The static assets can be served in two ways:

- With NGinx: this is the case of the *secure* example, in which we share the
  `public` directory between the NGinx and the Portus containers. This way, all
  assets are served directly and faster from the NGinx container. That being
  said, make sure to read
  [this note](http://port.us.org/docs/upgrading-portus.html#upgrading-with-docker-compose)
  from the documentation first if you are planning to deploy it this way, since
  it clarifies a common pitfall when upgrading Portus.
- With Rails by setting the `RAILS_SERVE_STATIC_FILES` environment variable to
  true. This is done in the *insecure* example, and it's recommended in
  scenarios where you don't want an extra container for managing your static assets.

## Acknowledgements

Many thanks to [@Djelibeybi](https://github.com/Djelibeybi), since we
borrowed a lot of the NGinx configuration from
[his repository](https://github.com/Djelibeybi/Portus-On-OracleLinux7).
