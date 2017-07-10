# Portus on Kubernetes

This example deploys the
[official Portus image](https://github.com/openSUSE/docker-containers/tree/master/derived_images/portus) on
top of a Kubernetes cluster. Some considerations:

- This example assumes that you want to make both Portus and the Registry
  available outside of the Kubernetes cluster. In order to do this, an
  `nginx/nginx.conf` file is provided, so you can setup an NGinx load balancer
  in front of the `portus` and the `registry` services. This example requires
  that you change the IP and the port to be used to the proper one (e.g. depends
  if you are using `NodePort` or `LoadBalancer`).
- This example is meant to be run in bare-metal. Because of this, services
  exposed to the outer world are of type `NodePort`. If you are deploying on
  top of GCE or Amazon, you should switch to `LoadBalancer` (note that the
  provided manifests files have comments on this as well, so it should be a
  matter of commenting/uncommenting).
- This example assumes that you already have a **working** Kubernetes
  cluster. How to setup a Kubernetes cluster is way beyond the scope of this
  example. For this, please check the Kubernetes documentation.

## How to run this

On a working Kubernetes cluster, execute the following:

```bash
$ ./create-secrets-from-files.sh
$ kubectl create -f manifests
```

After that, you should edit the provided NGinx configuration and change the
IP/Port of each service to the proper one (this depends on whether you used
`NodePort` or `LoadBalancer`). Note that we could have used something
like [confd](https://github.com/kelseyhightower/confd) to handle this
automatically.

After that, you should be able to use portus and this registry as usual.

## Services

We have three services:

- **mariadb**, which is of type `ClusterIP`.
- **registry**, which is of type `NodePort` (but can be easily changed to `LoadBalancer`).
- **portus**, which is of type `NodePort` (but can be easily changed to `LoadBalancer`).

The `portus` and the `registry` services are available through NGinx, which sits
in the router and makes sure that there is a single point of entry for both
services. This is not needed when using `LoadBalancer` for both of them.

## Secrets

There are quite some files deployed as secrets:

- Certificates: they are supposed to be located in the `certificates`
  directory. This secret is created by the `create-secrets-from-files` script.
- Registry's configuration: both an `init` script and the `config.yml`. The
  `init` script handles certificates for the registry and then runs it as usual.
- Secrets for mariadb and Portus. These secrets are provided in files
  (see [mariadb-secrets.yml](./manifests/mariadb-secrets.yml) and
  [portus-secrets.yml](./manifests/portus-secrets.yml)), but they should have
  been created better from the CLI.

## Volumes

This example is using the `hostPath` driver for simplicity. You should *never*
use this driver in production environments. Take a look at the [documentation on
this topic](https://kubernetes.io/docs/user-guide/volumes/).
