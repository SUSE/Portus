---
title: Configuring Portus
layout: post
longtitle: How to configure Portus
---

## The config.yml file

Before starting this application, you may want to configure some values that
are evaluated during the initialization process of Portus. All these values are
specified in the `config/config.yml` file. This file contains the default
values for each setting. In order to change these settings, you should create
the `config/config-local.yml` file and write your own values there. Note that
if you have your own `config-local.yml` file, then the definitive values will
be the result of a merge of both config files, where the settings of
`config-local.yml` take precedence. For example, imagine the following
situation:

{% highlight yaml %}
# In config.yml
settings:
  a: true
  b: false

# In config-local.yml
settings:
  a: false
{% endhighlight %}

The result of the previous example is that both `a` and `b` are false.

## Override specific configuration options

Besides the `config-local.yml` file, specific configuration options can be
tweaked through environment variables. These environment variables follow a
naming convention. Let's imagine the following configuration:

{% highlight yaml %}
feature:
  enabled: true
  value: "val"
{% endhighlight %}

In this case, the environment variables that can be used are `PORTUS_FEATURE_ENABLED` and `PORTUS_FEATURE_VALUE`. Therefore, the name of the environment variables always start with `PORTUS` and then they follow the name of the keys.

Note that environment variables override even values from the `config-local.yml` file. To sum this up, you can assume that Portus follows the following preference when reading a configuration value (listed from max. preference to least):

1. Environment variables.
2. The user-defined `config-local.yml` file.
3. The default values from the `config.yml` file.

## List of configuration options

### Gravatar

If enabled, then the profile picture will be picked from the [Gravatar](https://en.gravatar.com/) associated with each user. Otherwise, a default icon will be shown.

{% highlight yaml %}
gravatar:
  enabled: true
{% endhighlight %}

### Email configuration

{% highlight yaml %}
email:
  from: "portus@example.com"
  name: "Portus"
  reply_to: "no-reply@example.com"

  smtp:
    enabled: false
    address: "smtp.example.com"
    port: 587,
    user_name: "username@example.com"
    password: "password"
    domain: "example.com"
{% endhighlight %}

Note that if **smtp** is disabled, then `sendmail` is used instead (the specific command being: `/usr/sbin/sendmail -i -t`).

### LDAP Support

If enabled, then only users of the specified LDAP server will be able to use Portus.

{% highlight yaml %}
ldap:
  enabled: false
  hostname: "ldap_hostname"
  port: 389
  method: "plain"
  base: ""
  uid: "uid"

  guess_email:
    enabled: false
    attr: ""

  authentication:
    enabled: false
    bind_dn: ""
    password: ""
{% endhighlight %}

Some notes:

- **base**: The base where users are located (e.g. "ou=users,dc=example,dc=com").
- **method**: The method of encryption between Portus and the LDAP server. It defaults to "plain", which means that the communication won't be encrypted. You can also use "simple_tls", to setup LDAP over SSL/TLS. However, the recommended value is "starttls", which sets StartTLS as the encryption method.
- **guess_email**: Portus needs an email for each user, but there's no standard way to get that from LDAP servers. You can tell Portus how to get the email from users registered in the LDAP server with this configurable value.
- **uid**: The attribute where Portus will look for the user ID when authenticating.
- **authentication**: Some LDAP servers require a binding user in order to authenticate. You can specify this user by enabling this option. Then you should provide the DN of this user in the `bind_dn` value.

There are three possibilities for the **guess_email** option:

- disabled: this is the default value. It means that Portus won't do a thing when registering LDAP users (users will be redirected to their profile page until they setup an email account).
- enabled where "attr" is empty: for this you need "ldap.base" to have some value. In this case, the hostname will be guessed from the domain component of the provided base string. For example, for the dn: "ou=users,dc=example,dc=com", and a user named "mssola", the resulting email is "mssola@example.com".
- enabled where "attr" is not empty: with this you specify the attribute inside a LDIF record where the email is set.

If something goes wrong when trying to guess the email, then it just falls back to the default behavior (empty email).

### Creating the first admin user

As explained [here](/features/3_teams_namespaces_and_users.html), an admin user
can upgrade users to be administrators. But, how do we create the very first
admin user? There are two ways in which this can be done:

{% highlight yaml %}
first_user_admin:
  enabled: true
{% endhighlight %}

By default the first user to be created will be granted admin permissions. In
this case, when you go to the "Sign up" page, you will find the following
situation:

![Creating the Admin](/build/images/docs/create-admin.png)

That is, the "Sign up" form is telling you that the user to be created will be
an admin. Therefore, in order to create the first admin user, you just have to
proceed as usual and fill the "Sign up" form for this user. After doing this,
the "Sign up" form will not be able to create administrators, but only regular
users.

However, note if LDAP support is enabled, the first user that logs in with LDAP
credentials will be automatically an admin. This is shown in the following
screenshot:

![Creating the Admin in LDAP](/build/images/docs/create-admin-ldap.png)

The other way to do this is to disable the `first_user_admin` configurable
value. In this case, the first admin cannot be created from the Web UI, rather
you have to use the `portus:make_admin` rake task. Therefore, you should
access into the Portus application and run:

    $ rake portus:make_admin[<username>]

When Portus has been installed via RPM, this operation can be performed via
`portusctl`:

    $ portusctl make_admin <username>

### Enforce SSL usage on production

By default Portus will enforce usage of SSL when ran with the "production"
environment. This is required for security reasons. The behaviour is controller
by this configuration setting:

{% highlight yaml %}
check_ssl_usage:
  enabled: true
{% endhighlight %}
