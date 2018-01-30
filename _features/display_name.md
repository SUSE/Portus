---
layout: default
title: Display name
longtitle: Showing users by their preferred "display name" rather by their user names
order: 11
---

<div class="alert alert-info">
  Only available in <strong>2.1 or later</strong>.
</div>

## Display name

This can be useful in scenarios where users don't have a saying on their
username, but prefer to see something else (e.g. in LDAP). It should be
noted that this is just a mere aesthetical improvement: you cannot login
with this display name on either Portus or docker. For this reason, we thought
that, albeit necessary, it might be confusing to some users, so this feature is
disabled by default (take a look on how to enable this
[here](/docs/Configuring-Portus.html#display-name)).

### Setting up a display name

This can be done in two ways. First of all, if you are an admin, you can do
that by going to the users page on the `Admin` section and click a specific
user. You will see the following:

![Admin view of changing a display name](/images/docs/admin.png)

If you want to change your own display name (regardless if you are an admin or
not), then you can click your username on the top right corner to go your
profile. In there you will be able to change it on the "Public Profile"
container:

![Changing from the profile](/images/docs/user.png)

In the above example, if I set the display name to "Miquel", this is what I'll
see from now on:

![Display name changed](/images/docs/display_name.png)

As you can see, the name on the top right corner has changed to "Miquel". This
is what everyone will see from now on for this particular user.
