---
layout: default
title: OAuth and OpenID Connect support
order: 10
longtitle: Authenticate with an OAuth backend or an OpenID Connect provider
---

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

## OAuth and OpenID Connect support

You can tell Portus to use an OAuth or an OpenID Connect provider to login. The
currently supported providers are: Google, Github, Gitlab and Bitbucket. For the
full configuration read [this page](/docs/Configuring-Portus.html). An example
(with a Github provider):

![OAuth](/images/docs/oauth.gif)

Some things to note:

1. The password for the user is auto-generated. So, if you want to login
   afterwards with the given username and a password, you will have to go to
   your profile and change your password. Another possibility is to simply
   create an [application token](/features/application_tokens.html). This is
   also important if you want to login with the Docker CLI.
2. The callback URL to be used for each provider is different for each of them:
   - Google: `<host>/users/auth/google_oauth2/callback`
   - Open ID: `<host>/users/auth/open_id/callback`
   - Github: `<host>/users/auth/github/callback`
   - Gitlab: `<host>/users/auth/gitlab/callback`
   - Bitbucket: `<host>/users/auth/bitbucket/callback`
