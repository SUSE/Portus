---
layout: default
title: Locking accounts for safety reasons
order: 8
longtitle: Users that fail at logging in too many times will have their account locked
---

## Locking accounts

Portus implements the locking of accounts for users that have tried to log in
into Portus and failed just too many times. By default, users can fail 10
times before having their account locked. Note that in their last attempt,
users will get a warning:

![Warning](/images/docs/locking-warning.png)

After this warning, another attempt will result in the following situation:

![Locked](/images/docs/locked.png)

Subsequent attempts to log in with this account will result in the same
situation. Accounts are unlocked after 10 minutes since they have been locked.
