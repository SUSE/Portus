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

## Errors

### Authorization and authentication

In this regard there are two status codes to be aware of:

- `401`: an authentication error. This means that you either forgot to provide
  the `PORTUS-AUTH` header, or the given credentials are wrong.
- `403`: an authorization error. This means that the user performing an action
  is not allowed to do it.

### Data validation

In regards to data validation we differentiate between two kinds of
errors. First of all, we have type errors like:

- Some mandatory fields are missing.
- Some fields have a wrong type (e.g. a boolean value was expected but a weird
  string was given).

These errors are responded with a `400` status code. The response body will be
then like this:

```json
{
  "message": "Reason for the error"
}
```

Finally, the other possible error is a semantic one: a given field has a wrong
format (e.g. bad user email), a field was expected to be unique but it wasn't,
etc. These errors get back a `422` status code with the following response body:

```json
{
  "message": {
    "<field1>": ["<error1>", "<error2>", ...],
    ...
  }
}
```

### Unknown route or method not allowed

A `404` is returned whenever an unknown route is provided. This can happen in
two ways:

1. The given path is simply non-existent.
2. The path required a resource identifier (e.g. a user ID), but an unknown ID
   was provided (e.g. there are no users with the provided ID).

Sometimes it's not that the route does not exist, but that the given method is
now allowed at the moment. This can happen in some cases where the route is only
available under some conditions. In this situation, a `405` will be sent, with a
response body like so:

```json
{
  "message": "Reason for the method being disabled"
}
```

## Endpoints
