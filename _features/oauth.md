---
layout: post
title: OAuth and OpenID Connect support
order: 10
longtitle: Authenticate with an OAuth backend or an OpenID Connect provider
---

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

## OAuth and OpenID Connect support

You can tell Portus to use an OAuth or an OpenID Connect provider to login. The
currently supported providers are: Google, Github, Gitlab and Bitbucket. An
example (with a Github provider):

![OAuth](/build/images/docs/oauth.gif)

One thing to notice is that the password is auto-generated. So, if you want to
login afterwards with the given username and a password, you will have to go to
your profile and change your password. Another possibility is to simply create an
[application token](/features/application_tokens.html). This is also important
if you want to login with the docker CLI.
