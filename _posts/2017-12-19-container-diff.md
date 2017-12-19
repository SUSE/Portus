---
title: RPM support for container-diff
author: Valentin Rothberg
layout: blogpost
---

Google just recently released [container-diff](ihttps://github.com/GoogleCloudPlatform/container-diff) as an open-source project to share it with the containers community. The core use case of container-diff is to analyze container images and report differences among them, including installed software packages with respect to their name, version and size, but it can also analyze files on the images’ file systems.

The release of container-diff instantly caught the attention of the Kubernetes Core Team at SUSE, as we consider it to be a useful tool for the broader containers community, but also for our own open source projects. Analyzing and comparing the differences among containers can be a useful extension to Portus, and we will add support for it in the near future.  While Portus' [security scanning](http://port.us.org/2017/07/19/security-scanning.html) informs users about security issues in images and ultimately protects them from using insecure software, container-diff can assist in managing installed software packages in a more general fashion. For instance, container-diff can be used in automation to find out if or where a given software package is installed, reveal differences among those images, and assist in containerized software management.

SUSE knows that real-world IT systems are heterogeneous environments where products from different vendors are used to fit best to each individual need. Hence, one of the main goals of Portus' security scanning is to support not only the scanning of SUSE-based images via [zypper-docker](https://github.com/SUSE/zypper-docker), but to also to allow revealing vulnerabilities in non-SUSE based images, which we achieve by integrating [CoreOS clair](https://github.com/coreos/clair). Container-diff follows a similar philosophy and allows users to analyze images with software being installed by various package managers, such as apt for Debian-based images and pip for Python packages with more analyzers being added by the community. However, one missing piece in container-diff for SUSE was the support for RPM packages in order to support openSUSE and SUSE images, which has just been [contributed to upstream](https://github.com/GoogleCloudPlatform/container-diff/commit/a039c5878b41c13a991c5e0d3a05052b9881ccc6) by SUSE's Kubernetes Core Team.

At the moment of writing, container-diff ships two main functionalities. The first one is a basic analysis of the installed software packages in container images and tar archives. With the newly added RPM feature, analyzing an openSUSE image with container-diff can be achieved via `container-diff analyze --type rpm daemon://opensuse:tumbleweed`, which will load the `opensuse:tumbleweed` image from the local daemon, run the RPM analysis and report the results to the user:

```
-----RPM-----

Packages found in opensuse:tumbleweed:
NAME                            VERSION                      SIZE
-acl                            2.2.52                       216.6K
-bash                           4.4                          1M
-blog                           2.18                         128.9K
-bzip2                          1.0.6                        72.8K
...
```



Another core functionality of container-diff is to compare two specified container images or tar archives and output the software packages that are specific to one image, or common to both images. Comparing the `opensuse:42.2` with the `opensuse:42.3` image, for instance, can be achieved via `container-diff diff --type rpm daemon://opensuse:42.2 daemon://opensuse:42.3`:

```
-----RPM-----

Packages found only in opensuse:42.2:
NAME             VERSION        SIZE
-binutils        2.29.1         33.6M

Packages found only in opensuse:42.3:
NAME                VERSION        SIZE
-blog               2.18           129.2K
-libncurses6        5.9            1021.2K

Version differences:
PACKAGE                                   IMAGE1 (opensuse:42.2)        IMAGE2 (opensuse:42.3)
-gpg-pubkey                               307e3d54, 0                   3dbdc284, 0
-libblkid1                                2.28, 263.1K                  2.29.2, 271.1K
-libfdisk1                                2.28, 353.6K                  2.29.2, 369.6K
-libgcc_s1                                6.2.1+r239768, 90.5K          7.2.1+r253435, 90.4K
-libgpg-error0                            1.13, 254.7K                  1.27, 495.6K
-libmount1                                2.28, 294.5K                  2.29.2, 298.5K
-libp11-kit0                              0.20.3, 565.9K                0.20.7, 286.8K
-libsmartcols1                            2.28, 150.2K                  2.29.2, 162.2K
-libsolv-tools                            0.6.26, 4.3M                  0.6.30, 4.3M
-libstdc++6                               6.2.1+r239768, 1.5M           7.2.1+r253435, 1.5M
-libtasn1                                 3.7, 120.7K                   4.9, 91.9K
-libtasn1-6                               3.7, 78.6K                    4.9, 74.6K
-libuuid1                                 2.28, 18.2K                   2.29.2, 18.2K
-libzypp                                  16.15.6, 7.4M                 16.17.4, 7.4M
-openSUSE-release                         42.2, 1.3M                    42.3, 587.2K
-openSUSE-release-mini                    42.2, 67B                     42.3, 67B
-p11-kit                                  0.20.3, 224.4K                0.20.7, 236.4K
-p11-kit-tools                            0.20.3, 182.2K                0.20.7, 194.2K
-systemd-presets-branding-openSUSE        0.3.0, 892B                   12.2, 3.6K
-util-linux                               2.28, 3.6M                    2.29.2, 3.7M
-zypper                                   1.13.32, 6.6M                 1.13.38, 6.7M
```

All in all, [container-diff](ihttps://github.com/GoogleCloudPlatform/container-diff) is a great tool for containerized software management, and it integrates well in automation processes with new functionality being added by the community. Have fun, try it out, and contribute to upstream.
