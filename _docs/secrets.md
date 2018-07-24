---
layout: default
title: Using secrets
longtitle: How to use secrets in containerized deployments
order: 4
---

## Managing secrets

One of the most delicate things when deploying an application is managing
its secrets. In Portus you have two options:

1. **Environment variables**: you can set environment variables directly into
   your `docker-compose.yml` file, or the manifest you might be using. This has
   some downsides (e.g. it does not allow secrets rotation). For this reason,
   some container orchestrators like **Kubernetes** can manage secrets for you,
   and then store them in environment variables transparently. You can read more
   about Kubernetes secrets
   [here](https://kubernetes.io/docs/concepts/configuration/secret/) (and
   [this](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)
   section talks about setting environment variables with secrets).
2. **Files**: the other option is to simply have files for each
   secret. Orchestrators like Docker Swarm, Kubernetes, etc. support this
   workflow. In Portus we accomodate this a bit, and for some environment
   variables (`PORTUS_DB_PASSWORD`, `PORTUS_PASSWORD`, `PORTUS_SECRET_KEY_BASE`,
   `PORTUS_EMAIL_SMTP_PASSWORD` and `PORTUS_LDAP_AUTHENTICATION_PASSWORD`) we
   support a special syntax: you can add the `_FILE` suffix to it to indicate
   the path of the secret. So, for example, `PORTUS_DB_PASSWORD_FILE` would
   indicate the path of the secret for the database password.

<div class="alert alert-warning">
  <strong>Note well</strong>: all these secrets are loaded during
  <strong>initialization</strong>. Hence, if you want to <strong>update</strong>
  any of them, you will have to restart Portus.
</div>
