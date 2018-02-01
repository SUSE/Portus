---
layout: swagger
title: Portus REST API
longtitle: Specification of the Portus REST API
order: 5
data: api
---

## Introduction

We have been working on a REST API that can be used to operate Portus without
needing to access the web UI, and we are already building some tooling like
[openSUSE/portusctl](https://github.com/openSUSE/portusctl) which already takes
advantage of this new API.

Note though that we are doing organically. This means that we make no guarantees
over the stability of this version of the API (once we've learned what we need
from `v1`, we will make these guarantees on a [v2 version of the
API](https://github.com/SUSE/Portus/issues/1500)).

The specification listed below corresponds to the current state of the
**master** branch, so the specification may vary from the v2.3 release. That
being said, we are writing down the changes from the v2.3, so early users are
not caught off guard. Besides this, take into account the following:

- You have to set the `Content-Type` and the `Accept` headers to
  `application/json` for every request.
- Error messages are a bit chaotic (i.e. with different formats). We are
  tracking this on [this issue](https://github.com/SUSE/Portus/issues/1437).

## Authentication

Authentication is done through [application
tokens](/features/application_tokens.html). This way, you don't compromise your
password, and you can revoke it whenever you think it's necessary.

Once you have created this application token, you will have to pass the
`PORTUS-AUTH` header for every HTTP request that you perform. This header
follows this format: `<username>:<application token>`. So, if your user name is
`user`, and the application token you have created has the value
`T7Dfuz4fsy1UVxNUKyac`, then you have to set this header with the value:
`user:T7Dfuz4fsy1UVxNUKyac`. You can try that this is working by performing the
following HTTP request (where `https://172.17.0.1` points to a Portus instance):

```
$ curl -X GET --header 'Accept: application/json' --header 'Portus-Auth: user:T7Dfuz4fsy1UVxNUKyac' 'https://172.17.0.1/api/v1/users'
```

If everything went correctly, then you will get a JSON response with all the
users from your Portus instance.

Finally, [portusctl](https://github.com/openSUSE/portusctl) does this
automatically for you if you provide the environment variables:
`PORTUSCTL_API_SERVER`, `PORTUSCTL_API_TOKEN` and `PORTUSCTL_API_USER`. With
this in mind, the following is equivalent to the previously used curl command:

```
$ export PORTUSCTL_API_USER="user"
$ export PORTUSCTL_API_TOKEN="T7Dfuz4fsy1UVxNUKyac"
$ export PORTUSCTL_API_SERVER="https://172.17.0.1"
$ portusctl get users
```

## Endpoints
