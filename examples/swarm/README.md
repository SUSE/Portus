# Portus on Docker Swarm

> **Curently this example doesn't implement traffic encryption in any way, it would be considered foolish to run that in production**
>
> **TODO**: check if portus and claire handle '_FILE' environments so we can set the passwords in secrets

## Foreword

In our situation Swarm requires a routing service to expose service. To do this we rely on [traefik](https://traefik.io).

As it is present in our infrastructure, we leverage the container trafic router (traefik here) in place of Nginx in the docker compose examples.

Traefik is installed in a different stack and the traefik instance(s) are set on the "treafik-net" network. We don't define traefik into the portus stack because it would hinder its flexibility towards other stack that would be deployed.

Traefik has default rules to set ingress point for requests, by default it will get http requests on port 80. The example is considered insecure because nothing is done in it to encrypt any traffic. Encrypting traffic could be done by updating the ingress point to handle TLS (http redirection, tls, HSTS, acme -letsencrypt-, ...)

Each service that needs to be exposed out of docker swarm will need to be joined to the "traefik-net" network and have a set of labels enabling traefik to detect them and setup routing:

* ```traefik.enable=true```: enbables the route in traefik
* ```traefik.port=5000```: tels traefik on which port the service must recieve requests (here 5000 for registry)
* ```traefik.docker.network=traefik-net```: tels traefik on which network the service is exposed, this allows traefik to route the requests to the right internal ip when the service is connected to multiple networks
* ```traefik.frontend.rule=Host:portus;PathPrefix:/v2/```: tels traefik to route request matching the host and path to this service

We use traefik segments in the configuration to allow for multiple rules on one container (portus): for the port and rule definition you can add a segment name ```traefik.<segment>.port``` and ```traefik.<segment>.frontend.[...]``` to define multiple ports and rules.

The example is considered insecure because nothing is done in it to encrypt any traffic. Using traefik, we could configure traffic to force SSL (SSL redirect and HSTS) and render the instalation more secure.

Bellow a schema of how trafic is manged in the current example in its simplest form.

```asciiart
                           +---------------------------------------------+
                           | Docker swarm                                |
 _( )_                     |                                             |
/|   |\  http://portus:80  |  +---------+ "/"  +--------+   +---------+  |
  user -------------------->--> Traefik |------> Portus <---> MariaDB |  |
                           |  +---------+      +--^---^-+   +----^----+  |
                           |     |    \__________/    |          |       |
                           |     |     "/v2/token"    |     +----+----+  |
                           |     |                    |     | Portus  |  |
                           |     |     +----------+   |     +---------+  |
                           |     +-----> Registry |---+      background  |
                           |    "/v2/" +----------+  webhooks            |
                           +---------------------------------------------+
```

So basicaly:

* requests to ```http://portus/v2/token``` will be sent to portus
* requests to ```http://portus/v2/``` will be sent to registry
* requests to ```http://portus``` will be sent to portus

Notice that we didn't expose portus webhooks, that means that webhooks will only be available in the network for the portus stack.

> Some services will require docker volumes, as in swarm a container could be restarted anywhere, the use of a docker volume driver (s3, vmware, nfs, ...) is recommended.

To keep things as clear as possible the examples will start from this simple example. Ldap will be added afterwards as well as clair.

## Simple Insecure Portus

Portus have different default components:

* Portus: the service hosting the user interface of portus. This service also handles authentication for the registry.
* Registry: the docker registry. It will store your data (container images).
* Portus background: the service will handle webhooks and scan the repository
* MariaDB: this is the db used by portus to store its informations

Docker registry authentication is based on java web token. Portus will need rsa symmetric keys to sign the authenticaiton tokens. The docker registry will need the public part to verify the validity of the tokens. Even if this presented as a certificate, the essential part here are the rsa symmetric keys (which holds no metadata like hostname, expiration)

The docker registry needs a configuration file.

### Volumes

The registry will store your containers, if you want to keep them across reboots, a volume is necessary.

MariaDB is the database used by portus, if you want to keep portus state accorss reboots, a volume is necessary.

### Certificate

The portus public certificate is stored in a swarm configuration (ref. portus_crt).
The portus private key is stored in a swarm secret (ref. portus_key)

To generate new informations execute the following commands in the current folder:

```bash
> openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout ./secrets/portus.key -out ./secrets/portus.crt
```

### Registry configuration

The registry configuration is stored in a swarm configuraiton (ref. portus_registry).

> **TODO** check if registry can be configured via environment variables

### Environment variables

As some informations are repeated accross the compose file, environment variables are used.

* MACHINE_FQDN: the fully qualified domain name used by portus
* DATABASE_PASSWORD: the password used for the database
* SECRET_KEY_BASE: a secret hanlded by portus
* PORTUS_PASSWORD: the password of the portus user
* REGISTRY_SECRET: a secret shared by registries

## Enable Ldap

Enabling ldap is mainly adding de ldap environemnt variables to the main portus service.
The variables for ldap protocol encryption are absent: **LDAP requests won't be encrypted**.

Notice that we also added the mail guess part as the mail attribute is filled in in our LDAP.

## Enable clair

Clair is a image scanning solution allowing to check known vulnerabilities in a container. This can happen for different reasons, the main one would be old base image that have not been patched.

Clair consists in two extra services: clair and a postgresql needed for it.

Clair has its configuration setup in a swarm configuration.

Clair integration is setup in portus by enabling the environement variable in the main portus service.
