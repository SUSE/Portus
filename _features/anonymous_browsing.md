---
layout: post
title: Anonymous browsing
order: 7
longtitle: Explore public images from within Portus without logging in
---

## Anonymous browsing

<div class="alert alert-info">
  Only available in <strong>2.3 or later</strong>.
</div>

With this feature enabled, anonymous users will be able to search for public
repositories. That is, people will be able to search public images from your
registry without logging in. This feature is enabled by default:

```yaml
# Allow anonymous (non-logged-in) users to explore the images available in your
# Docker Registry. Only images on public namespaces will be shown.
anonymous_browsing:
  enabled: true
```

The following GIF will show you this feature in action:

![Explore](/build/images/docs/explore.gif)
