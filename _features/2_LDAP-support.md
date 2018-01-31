---
layout: default
title: LDAP support
order: 2
longtitle: LDAP user authentication
---

## LDAP user authentication

Portus can be configured to use an LDAP server for the authentication. This
means that in this case Portus will just act as a proxy between users and the
LDAP server for authentication. LDAP support is disabled by default, but it
can be enabled and configured by modifying the proper
[section](/docs/Configuring-Portus.html#ldap-support) in the `config/config.yml`
file.

Even if users are authenticated through the LDAP server, Portus needs to store
them in its database in order to perform all the interaction with the
registry. Moreover, each user will have a personal namespace, which will be
named after the given username. Bear in mind that [Docker's naming
rules](https://docs.docker.com/engine/reference/commandline/tag/).

might be more strict than what is required on your LDAP server. For this
reason, Portus will change the name of the personal namespace of users with a
username that contains characters that are not accepted by Docker rules. Users in
this situation will be notified on their first login in Portus. The implications
of this are:

- Users can use their LDAP credentials to login as usual.
- The name of the personal namespace will not be the same as the username if the
  name contains characters that are not accepted for namespaces.

For example, if a user with an LDAP username `mssola` tries to login, this same
user will have `mssola` as a personal namespace. However, if a user is named
`username$`, then this user can login with that username, but the personal
namespace will be `username`.

### Email guessing

Another issue to be discussed is the email. There is no standard way to specify
email accounts in LDAP servers, so everyone can do it in different ways. The
approach taken by Portus is to not do anything at all. In this case, no email
will be set when login for the first time, and the user will always be
redirected to a page asking for an email. This page looks like this:

![Profile page](/images/docs/email-guessing-fail.png)

Otherwise, you can tell Portus to be more clever and guess the email account
of each user. This can be done through the *guess_email* configurable value.
You can read more about this [here](/docs/Configuring-Portus.html#ldap-support).

### A note on security

When you login with `docker login`, you will see the following warning:

    WARNING: login credentials saved in /home/mssola/.docker/config.json Login Succeeded

If you take a look at that file, you'll see that the password is stored
in plain text (base64). This is an long-standing issue in Docker (see
[docker/docker#10318](https://github.com/docker/docker/issues/10318)).
