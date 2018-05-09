---
title: Configuring Portus
layout: default
order: 1
longtitle: How to configure Portus
---

## The config.yml file

Before starting this application, you may want to configure some values that are
evaluated during the initialization process of Portus. All these values are
specified in the `config/config.yml` file. This file contains the default values
for each setting, and you should *never* touch it. If you want to modify some of
its values you have two options: creating a `config/config-local.yml` file with
the values that you override the default ones, or to use **environment
variables**. For example, imagine the following situation:

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

In containerized deployments though, environment variables are usually more
convenient. Let's imagine the following configuration:

{% highlight yaml %}
feature:
  enabled: true
  value: "val"
{% endhighlight %}

In Portus we follow a **naming convention** for environment variables: first of
all we have the `PORTUS_` prefix, and then we add each key in uppercase. So, for
example, the previous example can be tweaked by setting:
`PORTUS_FEATURE_ENABLED` and `PORTUS_FEATURE_VALUE`.

Note that environment variables override even values from the `config-local.yml`
file. So, to sum this up, you can assume that Portus follows the following
preference when reading a configuration value (listed from max. preference to
least):

1. Environment variables.
2. The user-defined `config-local.yml` file.
3. The default values from the `config.yml` file.

Last but not least, some of these configuration values are quite delicate. This
is why you should manage them with secrets, [as explained
here](/docs/secrets.html).

## List of configuration options

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

### Gravatar

If enabled, then the profile picture will be picked from the [Gravatar](https://en.gravatar.com/) associated with each user. Otherwise, a default icon will be shown.

{% highlight yaml %}
gravatar:
  enabled: true
{% endhighlight %}

### Delete support

**Note**: bear in mind that this will only work accordingly if you are using
Docker Distribution 2.4 or later.

As of 2.1, and if you are using a Docker Distribution version not older than
2.4, you will be able to delete images, tags, users, namespaces and teams. In
order to do so just enable the `delete` option:

{% highlight yaml %}
delete:
  enabled: true
  contributors: false
{% endhighlight %}

This option is **disabled** by default. This is because we want users enabling
this if they are really sure about the feature itself and its requirements. For
more information, read [this page](/features/removing_images.html).

Moreover, this action can only be performed by team owners at first. You can
change this by setting `contributors` to `true`, in which case contributors will
also be able to remove images and tags.

### LDAP Support

If enabled, then only users of the specified LDAP server will be able to use Portus.

{% highlight yaml %}
ldap:
  enabled: false
  hostname: "ldap_hostname"
  port: 389
  method: "plain"
  base: ""
  filter: ""
  uid: "uid"

  authentication:
    enabled: false
    bind_dn: ""
    password: ""

  guess_email:
    enabled: false
    attr: ""
{% endhighlight %}

Some notes:

- **base**: The base where users are located (e.g. "ou=users,dc=example,dc=com").
- **filter**: This option comes in handy when you want to filter even further the results that might be hanging from the *base*.
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

![Creating the Admin](/images/docs/create-admin.png)

That is, the "Sign up" form is telling you that the user to be created will be
an admin. Therefore, in order to create the first admin user, you just have to
proceed as usual and fill the "Sign up" form for this user. After doing this,
the "Sign up" form will not be able to create administrators, but only regular
users.

However, note if LDAP support is enabled, the first user that logs in with LDAP
credentials will be automatically an admin. This is shown in the following
screenshot:

![Creating the Admin in LDAP](/images/docs/create-admin-ldap.png)

The other way to do this is to disable the `first_user_admin` configurable
value. In this case, the first admin cannot be created from the Web UI, rather
you have to use the `portus:make_admin` rake task. Therefore, you should
access into the Portus application and run:

    $ rake portus:make_admin[<username>]

When you are using the [official Docker
image](https://hub.docker.com/r/opensuse/portus/), you can do this with:

    $ docker exec -it <container-id> portusctl make_admin <username>

### Disabling the sign up form

By default Portus will have the sign up form available for any person that comes
across your Portus instance. You can change that by disabling the `signup`
configuration value:

{% highlight yaml %}
signup:
  enabled: false
{% endhighlight %}

This way, only the admins of this Portus instance will be able to create users
in the system. This setting is completely ignored when LDAP support is enabled.
This option is explained with more detail
[here](/features/disabling_signup.html).

### Enforce SSL usage on production

By default Portus will enforce usage of SSL when ran with the "production"
environment. This is required for security reasons. The behaviour is controller
by this configuration setting:

{% highlight yaml %}
check_ssl_usage:
  enabled: true
{% endhighlight %}

### OAuth support

**Note**: this is only available in Portus 2.3 or later.

Portus provides OAuth support: you can configure it to support authentication
from one of the supported platforms. Here is the full list:

{% highlight yaml %}
oauth:
  google_oauth2:
    enabled: false
    id: ""
    secret: ""
    domain: ""
    options:
      # G Suite domain. If set, then only members of the domain can sign in/up.
      # If it's empty then any google users con sign in/up.
      hd: ""

  open_id:
    enabled: false
    identifier: ""
    domain: ""

  github:
    enabled: false
    client_id: ""
    client_secret: ""
    organization: ""
    team: ""
    domain: ""

  gitlab:
    enabled: false
    application_id: ""
    secret: ""
    group: ""
    domain: ""
    server: ""

  bitbucket:
    enabled: false
    key: ""
    secret: ""
    domain: ""
    options:
      team: ""
{% endhighlight %}

All supported platforms have their own settings, but there are some common
attributes that might not be evident:

- *domain*: if a domain (e.g. mycompany.com) is set, then only signups with
  emails from this domain are allowed.
- *organization*, *group* and *team*: this is used by providers like Github,
  Gitlab or Bitbucket. With this you can restrict the team or organization where
  the given user belongs.
- OpenID's *identifier* and Gitlab's *server*: these attributes enable Portus to
  fetch the proper source. That is, you can specify the Gitlab server (by
  default gitlab.com), or the OpenID provider (by default you'll be prompted
  with a form asking for this information).

### Advanced registry options

You can configure some aspects on how Portus interacts with your Docker registry:

{% highlight yaml %}
registry:
  jwt_expiration_time:
    value: 5

  catalog_page:
    value: 100

  timeout:
    value: 2

  read_timeout:
    value: 120
{% endhighlight %}

The JWT token is one of the main keys in the authentication process between
Portus and the registry. This token has as one of its values the expiration
time of itself. The problem is that the registry does not request another token
when it expires. This means that for large images, the upload might fail
because it takes longer than the expiration time. You can read more about this
in the issue [SUSE/Portus#510](https://github.com/SUSE/Portus/issues/510).

To workaround this, we allow the admin of Portus to raise the expiration time
as required through the `jwt_expiration_time` configurable value. This value is
set in minutes, but we still allow the syntax as allowed before the 2.1 release
(deprecated in 2.3 and to be removed in 2.4).

Moreover, the registry might be slow or the network connection flaky. For this,
you can also use the `timeout` and the `read_timeout` values. This has been
added in Portus 2.3.

Finally, another option is the `catalog_page`. This tweaks the page size for
each catalog request performed by Portus. The default value for this should be
enough for the vast majority of users, but with this we allow administrators to
workaround a Docker Registry bug as stated
[here](https://github.com/SUSE/Portus/issues/1001).

### FQDN of your machine

On the next release of Portus, the FQDN of the machine is no longer a secret
and it's now considered a configurable value. The fact that it was a secret
before is because of legacy code. However, you now can configure it like this:

{% highlight yaml %}
machine_fqdn:
  value: "portus.test.lan"
{% endhighlight %}

### Security scanning

**Note**: this is only available in Portus 2.3 or later.

You can setup a security scanner for your Portus instance. This way, Portus will
display whether the images you have on your registry have known security
vulnerabilities. This feature is disabled by default, but it can be configured
through the following values:

```yaml
security:
  # CoreOS Clair support (https://github.com/coreos/clair).
  clair:
    server: ""
    health_port: 6061
    timeout: 900

  # zypper-docker can be run as a server with its `serve` command. This backend
  # fetches the information as given by zypper-docker. Note that this feature
  # from zypper-docker is experimental and only available through another branch
  # than master.
  #
  # NOTE: support for this is experimental since this functionality has not
  # been merged into master yet in zypper-docker.
  zypper:
    server: ""

  # This backend is only used for testing purposes, don't use it.
  dummy:
    server: ""
```

Portus supports having multiple scanners enabled at the same time. You can read
more about this [here](/features/6_security_scanning.html).

### Anonymous browsing

**Note**: feature only available in Portus 2.3 or later.

You can configure Portus to allow anonymous users to explore public
repositories. This feature is enabled by default:

{% highlight yaml %}
anonymous_browsing:
  enabled: true
{% endhighlight %}

You can read more about this [here](/features/anonymous_browsing.html).

### Display name

This option tells Portus to not use the username when showing users, rather a
user-defined "display name". You can read more about this
[here](/features/display_name.html). By default this feature is disabled, and
it's controlled with this setting:

{% highlight yaml %}
display_name:
  enabled: false
{% endhighlight %}

### Granular user permissions

You can further tweak the permissions that users have on a Portus instance with
the following options:

{% highlight yaml %}
user_permission:
  change_visibility:
    enabled: true

  create_team:
    enabled: true

  manage_team:
    enabled: true

  create_namespace:
    enabled: true

  manage_namespace:
    enabled: true

  push_images:
    policy: allow-teams
{% endhighlight %}

- **change_visibility**: allow users to change the visibility or their personal
  namespace. If this is disabled, only an admin will be able to change this. It
  defaults to true.
- **create/manage_team**: allow users to create/modify teams if they are an
  owner of it. If this is disabled, only an admin will be able to do this. It
  defaults to true.
- **create/manage_namespace**: allow users to create/modify namespaces if they
  are an owner of it. If this is disabled, only an admin will be able to do
  this. It defaults to true.
- **push_images**: set a push policy. Available options are: `allow-teams`,
  `allow-personal` and `admin-only`. You can read more about push policies
  [here](/features/3_teams_namespaces_and_users.html).

### Background process

**Note**: this is only available in Portus 2.3 or later.

As explained in the [documentation page](/docs/background.html) of the background
process, we have introduced a background process to alleviate some heavy
operations from the main Portus process. This background process has its own
configuration values:

{% highlight yaml %}
background:
  registry:
    enabled: true

  sync:
    enabled: true
    strategy: initial
{% endhighlight %}

- The `security scanning` task can be disabled by not providing a server as
  described [here](/docs/Configuring-Portus.html#security-scanning).
- The `registry` integration can be disabled, but it is **highly discouraged**
  since then all registry events will be missed by Portus (they will be logged,
  but not handled).
- The `sync` task can be disabled as well, but more importantly you can tune it
  further when enabled with the `strategy` option. This option may have any of
  the following values:
  - **update-delete**: it performs a full synchronization (traditional behavior
    of the old `crono` process).
  - **update**: it only adds missing tags, but it does not remove any contents
    from the database.
  - **on-start**: when starting Portus it runs an `update-delete` and then it
    gets disabled (i.e. it will only run once).
  - **initial**: like `on-start`, but it only runs if the database is
    empty. This is the default value since it's deemed to be the most common
    use-case and the safest option. The idea behind this option is that you only
    want to synchronize when bootstrapping your instance.

### Pagination

**Note**: feature only available in Portus 2.4 or later.

You can configure how pagination behaves regarding table entries and the pages
component. The `limit` attribute refers to the number of entries per page that
should be displayed and `before_after` to the number of pages to be displayed
before and after the current page in the pages component. The default values are
descibred as below:

{% highlight yaml %}
pagination:
  limit: 10
  before_after: 2
{% endhighlight %}


## Deploying Portus in a Sub-URI

In some deployments it might make sense to make Portus accessible through a
Sub-URI. That is, to be able to prefix requests to Portus with a subdirectory.
In non-passenger setups, this can be accomplished by setting the
`RAILS_RELATIVE_URL_ROOT` environment variable. With this, you will be able to
serve Portus from the specified subdirectory.
