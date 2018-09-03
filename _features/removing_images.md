---
layout: default
title: Removing images and tags
order: 5
longtitle: Removing images and tags from the registry through Portus
---

<div class="alert alert-info">
  Only available in <strong>2.1 or later</strong>.
</div>

## Intro

One of the most remarkable features from the 2.1 release is the ability to
remove images and tags. This has not been possible until now because, even
though it has always been possible to delete an image by manifest (*soft
delete*), the orphaned blobs couldn't be properly removed. Therefore, we
decided that it was better to not provide this feature at all because otherwise
we would be lying to our users (by saying that an image was deleted when in
fact it wasn't really).

Fortunately, Docker Distribution 2.4 implemented a Garbage Collector, which
basically removes all the blobs that have been orphaned (no manifest is
referencing them). We have two challenges though:

1. Maintenance has to be done manually (see [Maintenance](#maintenance)).
2. Portus has no way to check the version of the running registry, so the
   administrator has to
   [explicitly enable this](/docs/Configuring-Portus.html#delete-support).

Note that this feature has to be enabled from the registry's side too. This can
be enabled by setting the
[storage/delete](https://github.com/docker/distribution/blob/master/docs/configuration.md#delete)
option to true.

## Removing images & tags

Removing images and tags is quite intuitive from a user point of view. Just go
to the repository page:

![Repository page](/images/docs/repo-images.png)

In there, you can see trash cans. Click on any of them and a confirmation form
will pop up. If you agree, then you will have removed the specified tag or
image. Moreover, all this is still tracked in the activities list. For
example, let's say that in the previous example we removed the `latest` tag.
Then we would have the following activities list:

![Activities of removing a tag](/images/docs/repo-activities1.png)

Now, in the same repository page, if we want to remove the image and all its
tags, we can just simply click on the "Delete image" link located on the top
right corner of the page. In the previous example, if now we removed the whole
image, we would get the following activities list:

![Activities of removing an image](/images/docs/repo-activities2.png)

## Maintenance

The Garbage Collector (GC from now on) is a crucial part on this feature and
it's implemented by Docker Distribution. The bad thing is that it has been
provided as a separate command. This means that administrators have to call
this command explicitly instead of it being handled automatically for us.
Moreover, in order to do it safely in production, some downtime is to be
expected: you can run the GC anytime you want but it will bring concurrency
issues if executed when some pushes were being performed. You have two ways to
avoid concurrency problems:

1. If you are expecting the GC to be fast, then stopping the registry, running
   the GC and restarting the registry again should do the trick.
2. If you expect the GC to take a fair amount of time, then we recommend to
   restart your registry in [read-only
   mode](https://github.com/docker/distribution/blob/master/docs/configuration.md#read-only-mode)
   and perform GC then. Once GC is over, you can restart your registry again
   with read-only mode disabled.

As you can see, there is no way around this: you have to expect some downtime
if you want to do some cleanup in your registry. One reasonable question for
this situation is: how do I know whether the GC process is going to take a
long time or not? There is no hard rule for it but our experience tells us
that you will have to proceed with the second point above if you have quite
some images stored in a cloud storage service like Amazon's S3. That is, the
main bottleneck is accessing your storage service, othewise GC should be fast.

Despite this inconvenience in maintenance, running the GC is actually quite
simple. You just have to call the registry command with the new
`garbage-collect` command. It accepts one argument: the configuration file.
Moreover, if you just want to check whether there are orphaned blobs or not,
you can simulate the garbage collection by using the dry-run mode with the
`-d` flag.

## Automating the removal of images and tags

<div class="alert alert-info">
  Only available in <strong>2.4 or later</strong>.
</div>

The `delete` option from the Portus configuration contains also another section:
`garbage_collector`. This is not the garbage collector as described from the
registry. Instead, it allows administrators to setup Portus so images considered
old are deleted. The section is as follows:

{% highlight yaml %}
garbage_collector:
  enabled: false
  older_than: 30
  tag: ""
{% endhighlight %}

Some notes:

1. It's disabled by default.
2. `older_than` specifies the number of days in which an `image:tag` is
   considered old. By default, an image older than 30 days will be considered
   old.
3. `tag` is a filter that acts over old tags. That is, if you specify a value,
   then only old tags that follow the given format will be automatically
   removed. This option is expected to be a valid regular expression. Some
   examples:
    - `jenkins`: if you anticipate that you will always have a tag with a
      specific name, you can simply use that.
    - `build-\\d+`: your tag follows a format like "build-1234" (note that
      we need to specify `\\d` and not just `\d`).
