---
layout: post
title:  "Additional features"
date:   2015-06-24 17:27:10
categories: documentation
---

## Audit

One additional feature of Portus is that it monitors and registers all the activities that users perform on the application. It registers the following kinds of actions:

- A team has added/removed a member.
- A team has changed the permissions of a member.
- A namespace has been created.
- A namespace has been made public/private.
- A repository has been pushed.

All this information is stored in the database, so it can be visualized later on in either the "Activities" tab or the "Admin" one. The "Activities" tab is the one selected when you first enter in Portus and it shows all the activities that are relevant to the current user. An example:

![Current user activities](https://github.com/SUSE/Portus/blob/master/doc/activities.png)

The "Admin" page shows some statistics about the application, and in the bottom you can see a list of activities. This list differs from the one that you can see in the "Activities" tab by listing all the activities, regardless if it's relevant to the current user or not. Therefore, an admin user will always have the possibility of monitoring the actions of the users in this application. However, this page is limited to 20 activities. If you want to view all the activities, you'll have to click at the link saying "View all activities". If you click this, you'll find the following:

![Admin activities](https://github.com/SUSE/Portus/blob/master/doc/admin-activities.png)

As you can see, this is the same list as the one shown in the admin page, but this one is not limited to 20 activities. Moreover, as you can see, in the top right corner there is a button for downloading a CSV file with all the activities.

## Search

Portus has the ability to search for repositories. The searching is done by clicking on the search element that can be found in the top bar. After doing this, you can write what you're looking for and click enter. Something like this:

![Search](https://github.com/SUSE/Portus/blob/master/doc/search.gif)

The found repositories abide to the permissions of the current user. Therefore, it's not possible for a user to accidentally find a repository that is out of his scope.
