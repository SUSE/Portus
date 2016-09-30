---
layout: post
title: Removing/Disabling users
order: 7
longtitle: Disable users temporarily, or remove them from the system
---

## Removing users

Since Portus 2.1, administrators can remove users from the database
completely. You can do this by going to `Admin` section and into the `Users`
page. In there, you'll see a trash can for each user:

![Removing](/build/images/docs/remove-user.png)

You can also do this from the user's profile:

![Removing](/build/images/docs/remove-user-profile.png)

## Disabling users

Any admin can disable users. The only restriction is that an admin user cannot
disable itself if it's the only remaining admin in the application. You can
disable any user by accessing the "User" panel in the "Admin" page. Just like
this:

![Disabling](/build/images/docs/disabling-user.png)

No data will be lost by disabling a user. The only thing that will happen is
that disabled users won't be able to login into Portus. This is what a disabled
user will see when trying to login:

![Disabled](/build/images/docs/disabled-user.png)

Of course, in the same way that an admin can disable a user, an admin can
enable back a disabled user. The procedure is exactly the same: just click
the "Enabled" toggle again.
