---
layout: post
title: Application tokens
order: 11
longtitle: Use Application tokens for improved security
---

## Application tokens

### Why do we need application tokens ?

Every time that you execute `docker login` on the terminal, you will get the
following output:

    WARNING: login credentials saved in /home/mssola/.docker/config.json

Now, if you take a look at the contents of the file, you will be able to read
something like this:

{% highlight json %}
{
  "auths": {
    "my.registry:5000": {
      "auth": "dXNlcjoxMjM0NTY3OAo=",
      "email": "user@example.com"
    }
  }
}
{% endhighlight %}

This file contains all the information that the Docker daemon needs in order to
authenticate to known registries. This way, Docker doesn't have to ask users
the credentials every time they perform operations on known registries. Now,
avid users will detect that this `auth` string does not look secure enough. In
fact, this value contains the login and password that you have used for this
registry in `base64`. If you want to test this out, you can perform the
following on the command line:

    $ echo "dXNlcjoxMjM0NTY3OAo=" | base64 --decode

The output is `user:12345678`, which is what we have used for this example.
This is bad, especially if you are using your LDAP account. This is a known
problem, and it's being discussed in this
[Docker issue](https://github.com/docker/docker/issues/10318).

In order to fix this situation, Portus allows users to create random
application tokens. You may use application tokens when being asked for the
password after running `docker login`. This way, if your home directory gets
compromised, the `$HOME/.docker/config.json` will only contain application
tokens, thus not compromising anything else (e.g. as it would happen if those
credentials were the ones you are using for LDAP). In this scenario, you can
access Portus and revoke all your Application tokens.

<div class="alert alert-info">
  <strong>Note well</strong>:
  Application tokens are not accepted to authenticate to Portus' web interface.
</div>

### Adding and Removing Application tokens

First of all, go to your profile page. You can do that by clicking on your name
on the top right corner. In this page, you should be able to see the following:

![Application Token container](/build/images/docs/application-tokens.png)

If you click on "Create new token", a form will appear, asking you to provide a
name. After that, click "Create", and you will get the following message on the
top of the page:

![Token create](/build/images/docs/token-created.png)

<div class="alert alert-info">
  <strong>Note well</strong>:
  it's not possible to recover the value of your application tokens. They are
  visible only right after their creation. So please write down their values
  somewhere safe.
</div>

That's it, this is the value of the token that you can now use to authenticate
yourself. Moreover, you can add up to 5 different Application tokens. Finally,
in the same way that you can create tokens, you can remove them:

![Remove token](/build/images/docs/remove-token.png)

### What's next ?

From now on, you can use Application tokens to handle your passwords inside of
Portus without beign afraid of writing your actual password to disk. Moreover,
we have plans to expand on this idea, so stay tuned!
