---
layout: post
title: LDAP support
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
them in its database in order to perform all the interaction with the registry.
Because of this, you have to be aware that some of the characters that are
allowed in the user name on an LDAP server are not allowed in Portus (this is
a restriction from Docker). Portus will try to generate a new name for invalid
names (by removing invalid characters, and appending a random number to it if
it clashes). This given name is the one that will be used when interacting
with namespaces and the registry. To put it simply:

- The real LDAP name is only used for authentication (both in Portus, and in
  the Docker CLI).
- The generated name is the one that will be used for creating the user's
  namespace.

### Email guessing

Another issue to be discussed is the email. There is no standard way to specify
email accounts in LDAP servers, so everyone can do it in different ways. The
approach taken by Portus is to not do anything at all. In this case, no email
will be set when login for the first time, and the user will always be
redirected to a page asking for an email. This page looks like this:

![Profile page](/build/images/docs/email-guessing-fail.png)

Otherwise, you can tell Portus to be more clever and guess the email account
of each user. This can be done through the *guess_email* configurable value.
You can read more about this [here](/docs/Configuring-Portus.html#ldap-support).

### A note on security

When you login with `docker login`, you will see the following warning:

    WARNING: login credentials saved in /home/mssola/.docker/config.json Login Succeeded

If you take a look at that file, you'll see that the password is stored
in plain text (base64). This is an long-standing issue in Docker (see
[docker/docker#10318](https://github.com/docker/docker/issues/10318)).
