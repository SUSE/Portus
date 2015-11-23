---
layout: post
title: Disabling the sign up form
longtitle: Disable the possibility of users signing up on their own
---

## Disabling the sign up form

You can disable the sign up form in Portus' configuration as explained
[here](/docs/Configuring-Portus.html#disabling-the-sign-up-form).
Since anonymous users will no longer be able to access the signup form, then it
will be up to administrators of the Portus instance to sign up new users into
the system. An admin user can do this in two ways: through a form provided in
the admin section, or with a simple rake task.

### The form on the admin section

Just access the admin section and click on the `Users` container. By doing so,
you will access to the users section, and it should be similar to this:

![Users](/build/images/docs/users-panel.png)

As you can see in the image above, in the top right corner of the users list
there is a link for creating a new user. Click it and you will access the
following form:

![Create user](/build/images/docs/new-user-form.png)

### The rake task

If you have access to the server directly, you can call the following rake
task:

    $ rake portus:create_user[username,email@example.com,password,false]

If you have installed Portus from the [RPM](/docs/setups/1_rpm_packages.html),
you can also use `portusctl` for that:

    $ portusctl rake portus:create_user[username,email@example.com,password,false]

Note that if you have installed Portus from the RPMs, it's better to use
`portusctl`, since it will always pick the right gems.

## The password for created users

Portus is flexible enough so you don't have to overcomplicate the process of
creating new users. In this case, you can setup whatever password you wish for
the created users, and then tell said users to immediately change their
passwords by accessing their profile pages.
