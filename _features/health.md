---
layout: post
title: Health checking
order: 12
longtitle: Check the status of the different components of your deployment
---

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

## Ping

Portus has the `/_ping` endpoint exposed, so anyone can check whether it is up
and running. Portus will return an empty `200 OK` response. For example:

```
$ curl -X GET -I https://registry.mssola.cat/_ping
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 04 Aug 2017 11:09:42 GMT
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Cache-Control: no-cache
X-Request-Id: f23617bd-6732-433f-a9b6-1bc5717e345e
X-Runtime: 0.091130
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
```

## Health check

There is another endpoint which is a bit more complex than the ping one:
`/_health`. This will return a JSON body with the status of the different
components. For example:

```
$ curl -X GET https://registry.mssola.cat/_health | jq
{
  "database": {
    "msg": "database is up-to-date",
    "success": true
  },
  "registry": {
    "msg": "registry is reachable",
    "success": true
  },
  "clair": {
    "msg": "clair is reachable",
    "success": true
  }
}
```

Some notes:

- `database` also reports when the DB is still initializing, among other
  things.
- `registry` not only check that the registry can be ping'ed, but it also
  performs checks: the idea is that the registry should not only be ready, but
  also usable.
- `clair` is shown in the above example because Portus was configured with
  [clair support enabled](/features/6_security_scanning.html). If this is not
  the case, then this check will be skipped.

### Clair and its health check

Clair exposes the health check API on another port (see [its
documentation](https://coreos.com/quay-enterprise/docs/latest/clair.html)). Because
of this, we provide the `health_port` value in the Portus configuration. This
has been set to the default value of Clair: 6061. If you want to change this,
just set the `PORTUS_SECURITY_CLAIR_HEALTH_PORT` environment variable, or
provide a `config-local.yml` file like so:

```yaml
security:
  clair:
    server: "http://my.server"
    health_port: 6062
```
