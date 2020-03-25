## Upcoming Version

## 2.4.3

- f4d6914850a4 Upgraded the omniauth-google-oauth2 gem
- 67a0d4c0f54b Fix style inconsistencies on password reset pages

## 2.4.2

- e960c96dc821 Fixed nil exceptions for activities
- 627a990b9829 Fixed all? and delete? namespace policies
- 56385ecf8bc6 Fixed deletion for registry 2.7

## 2.4.1

This release consists mostly of bug fixes and upgrades from vulnerable
gems. Thank you everyone involved!

- af08f6211abb db: added index on scan_result
- a282fff71bd4 Properly show tokens for bots
- a55c0ec2f827 Upgraded cconfig to fix a configuration issue
- d3be549af55f Fixed namespace duplication
- 3591e04ba75c ui: fixed team creation for standard user
- 52915908e36b ui: fixed repositories performance view issue
- 69e41ece3f8a Reduced amount of rendered data for repository entity
- 942f18113fa1 Fixed breaking changes from pagination commit
- 762c9665bb11 policies: fixed destroy for repositories/tags
- Upgraded the following gems due to vulnerabilities:
  - 5f90273e0b9a nokogiri
  - 351fc7d27b3e loofah
  - d3be549af55f rack
  - ae62d4c4c0b7 rails

## 2.4.0

### Highlight

#### Configuration changes

We have introduced quite some configurable options. Some of them are new, and
some other are merely additions to existing ones.

First of all, we have expanded the configuration for the mailer. We are now
providing more options so administrators have more flexibility in regards to how
they manage SSL/TLS. You can read the update documentation of the mailer
[here](http://port.us.org/docs/Configuring-Portus.html#email-configuration).

Moreover, the `delete` option has now two new options:

1. You can allow contributors to delete namespaces/repositories/etc. with the
   `delete.contributors` option (it's set to `false` by default).
2. The background process can now automatically remove images that are older
   than a certain date, or that match a given tag. This is disabled by default
   and it's under the `delete.garbage_collector` option.

You can read more about this
[here](http://port.us.org/docs/Configuring-Portus.html#delete-support).

LDAP has also seen some updates. First of all, this release includes the changes
described in the `2.3.3` release when it comes to encryption, but it also adds
the new `timeout` option, in which you can tune the timeout in seconds for LDAP
lookups. You can read more about this
[here](http://port.us.org/docs/Configuring-Portus.html#ldap-support).

We have also expanded the `user_permission` section, so administrators can
further tune what regular users can do. In more details:

- We have added the `create_webhook` and the `manage_webhook` options, in order
  to restrict webhook management (it is not restricted by default).
- We have added the `push_images` option, which accepts three possible values
  under its `policy` key:
  - `allow-teams`: the default policy, which works as how Portus used to work up
    until now: owners and contributors of teams can push.
  - `allow-personal`: team policy is removed, non-admin users will only be able
    to push into their personal namespaces.
  - `admin-only`: only administrators are allowed to push images.

You can read a summary of the `user_permission.push_images` option
[here](http://port.us.org/features/3_teams_namespaces_and_users.html#summary-with-all-the-options).

Furthermore, you can now also tune the `pagination` rule being applied to all UI
elements which contain a list (e.g. the list of repositories).

Last but not least, we have increased the default value for the JWT token
expiration time, since it has been reported that the default value was just too
small.

#### Moved portusctl into another project

The `portusctl` tool has been rewritten and moved into its own
[project](https://github.com/openSUSE/portusctl). This has allowed us to expand
its possibilities, since now it will mainly interact with your Portus instance
through the API. The interface of this tool has changed quite a lot, but we
kept the ability to execute commands inside of your Portus instance (i.e. the
existing `exec` command). This new tool is already included in Docker images
based on this `2.4` version of Portus.

#### Changes on the API

We have added new endpoints, as you will see on the list below. We would like to
highlight the `bootstrap` endpoint. This endpoint allows an administrator of a
Portus instance to create the first admin user of Portus and to fetch an
application token that has been created for this same user. This way, you no
longer need the UI in order to perform the first steps of your instance.

Besides this, the Portus UI itself is using more and more this API, instead of
using a more traditional approach. Last but not least, we have changed existing
endpoints with more refined status codes, better response objects, etc. Make
sure to visit the [API documentation](http://port.us.org/docs/API.html).

#### Added bots

We have introduced a new concept: bots. Bots are regular users that are created
by administrators, but with some subtleties:

- A bot doesn't own a personal namespace.
- A bot cannot login via web.
- A bot can only log in with application tokens (a token is generated
  automatically when creating a bot).

#### Namespace deletion

After much delay, we have implemented namespace deletion. You don't have to
change anything from your configuration in order to have this enabled (it
depends on the same `delete.enabled` configuration).

### Features

- 20c7e04acdfb Local login form can be disabled (#1603)
- 23e455516156 webhooks: added the name column (#1581)
- 53ce8967395b Allow contributors to delete repositories/tags (#1696)
- 0c0d46b67f6c config: added option to generally disable push access to non-admin users (#1705)
- f0432d102b49 api: added bootstrap endpoint (#1681)
- 2fcbeda7edbb api: added update methods for namespaces and teams (#1794)
- c9e32324a848 Added permissions on webhooks (#1806)
- bf4e913552b8 config: removed the deprecated `ldap.method` key (#1821)
- 7f82a44078c3 Added the possibility to create bots (#1856)
- 5ee93c4b1b96 background: implemented garbage collector (#1864)
- 94f78377e699 Implemented namespace deletion (#1938)

### Fixes

- 0b7a651e8114 api: take the relative url root into account (#1610)
- 7b28926a34b8 api: removed slash duplication from ajax calls (#1628)
- 57d1f93f9931 health: don't panic on malformed Clair URL (#1665)
- e85ed519974d Increased the text storage for vulnerabilities (#1670)
- 02d387363881 sync: rollback if events have happened (#1675)
- 7e60b7155429 sync: added sync-strategy as a config value (#1675)
- 459c1953a0f9 security: don't crash on clair timeouts (#1762)
- 640e48c7b9a4 security: fetch the manifest more safely (#1768)
- b97636183d0e sync: do not remove repositories on some errors (#1787)
- 83b4b3a9fa97 ui: fixed hostname copied to clipboard on tags (#1792)
- 4625761e8ede api: explicitly set 204 status instead of nothing (#1804)
- ae80df228db8 ldap: fixed a couple of bugs around SSL support (#1817)
- 4c25b2367349 health: catch all exceptions for registries (#1831)
- 291b049e1e8d ldap: fixed a crash when search fails (#1834)
- fc133a48787f user: do not allow the update of the portus user (#1896)
- cef7f4c506bd passwords: don't allow the portus user to reset (#1896)
- 67ba269d33ee user: skip validations when creating portus user (#1896)
- 9af3f2277d7b Restrict deletes into the repository (#1973)

### Improvements

- 9aa3ee218ffd api: added create and update methods to registries (#1663)
- aa3ccb19132e background: mark failed scans as re-schedulable (#1671)
- 54dade970964 api: added endpoints for re-scheduling scanning (#1672)
- cc6e5046a441 background: add the possibility to disable background tasks (#1679)
- e6683066f3d8 config: make reply_to setting optional (#1699)
- 07d33f4ad80b policies: added more fine-grained push policies (#1729)
- 02fec6da7996 teams: improved team creation form with owner (#1776)
- 10ab3456bc4d security: added a table for vulnerabilities (#1778)
- ee295ee896e0 ui: added users and registries into the sidebar (#1784)
- d2d90d424555 ui: splitted repositories into different panels (#1785)
- 6482ed7522f5 ui: unified admin page with regular page (#1783)
- 6cd886a4fad0 ui: show external hostname for registries (#1791)
- 49c6aefd1e76 authentication: use a more fine-grained scope for Github (#1800)
- c524f37461ff ui: added visibility to namespace edit form (#1826)
- a80fbaa0e880 ui: added enabled toggle to webhooks edit form (#1827)
- a6f6035d40b9 health: implemented check for LDAP (#1828)
- ccdbd31bea78 js: replaced typeahead.js w/ vue-multiselect (#1811)
- ec6adb71f521 ui: improved and refactored namespace#show page (#1837)
- 6cd0af5f4b93 js: reduced bundle size (#1891)
- f777a5effb16 oauth/gitlab: allow to use private gitlab server (#1903)
- f1e8a103dfa4 oauth/gitlab: be sure to load all groups (#1903)
- 10cb892b0b24 docker: allow Puma to bind to unix socket also in production (#1880)
- 4b57ad666846 docker: make it possible to connect to a database socket (#1880)
- 82199e9ade87 js: splitted into bundles and chunks (#1924)
- 990a04e36116 config: raise the default puma workers number (#1938)
- 688cb501f7cf config: expanded the mailer section (#1967)
- bef0fe19d3a5 config: added pagination options (#1815)
- 35ba42f2a4f1 config: added LDAP timeout option (#1821)
- 648450748bed Remind users to login again after password update (#1969)
- 914cc9ebfdee tasks: added portus:db:configure (#1970)
- bc28c049bd10 config: raised the value for JWT expiration time (#1979)

### Packaging

- 279de0a3762b Add "js()" to the bundled javascript libs (#1744)
- 66bcd6a58b28 Including gems as sources (#1948)
- e3ddaa042154 Require portusctl as a separate package (#1948)
- a6a3a36b00c6 Add automatic generation of bundled js files (#1948)
- 89566d7da334 Do not recommend mariadb (#1948)
- e350e0cae365 Define rb\_suffix before its usage in fix\_sheb (#1948)
- 556778b9f3aa Using the cpio strategy for adding/removing gems as sources (#1962)

### Other

- c97663be06cd Removed deprecated code from 2.3 (#1604)
- 3b912ebd1684 help: point to the API documentation on production (#1647)
- 190edbaea06c Introduced unit testing for Javascript components (#1592)
- ecca2d9c6336 js: added unit tests for vue components and utils (#1661)
- f297fd71618b Re-implemented from scratch integration tests (#1716)
- d534723aa762 spec: added chrome headless as default js runner (#1866)

## 2.3.7

- ad5d649a3344 Upgraded some gems with known vulnerabilities.

## 2.3.6

- 81179951f458 Restrict deletes into the repository (#1973)
- 066f06f4e713 Remind users to login again after password update (#1969)

## 2.3.5

- 7755c7201d61 Update sprockets to fix cve-2018-3760

## 2.3.4

- ced82ca92149 oauth/gitlab: be sure to load all groups (#1903)
- 23b7daef71e8 oauth/gitlab: fix for local servers (#1903)
- f2a3ef0eee62 fixed regression on registries not being created (#1911)
- 7da007a5e604 portusctl: improved the detection of containerized deployments (#1879)
- b1c803a70146 user: do not allow the update of the portus user (#1896)
- 1bd967039787 passwords: don't allow the portus user to reset (#1896)
- 7b54698625d4 user: skip validations when creating portus user (#1896)
- 58a2c3bd04dc config: allow Puma to bind to unix socket also in production (#1880)
- 7ac882a6ebbc config: make it possible to connect to a database socket (#1880)

## 2.3.3

- 93df51cce0da ldap: don't crash on search when guessing an email (#1832)
- 45814babef7e packaging: added new encryption options for LDAP
- 4892eb1dc5ce ldap: fixed a couple of bugs around SSL support (#1746, #1774, bsc#1073232)
- dc769adcddfe devise: use a more fine-grained scope for Github (#1790)
- ae07ec4ca2cd sync: do not remove repositories on some errors (#1293, #1599)
- 17e82c0791ba lib: be explicit on the exceptions to be rescued
- 88553b817552 portusctl: added Clair timeout to the options
- fed2818e8a96 security: fetch the manifest more safely (#1743)
- 943c7627feab security: don't crash on clair timeouts (#1751)

### Words of warning

Commits 45814babef7e and 4892eb1dc5ce introduce some new options for LDAP. In
particular, the following options have been added inside of the `ldap`
configuration:

```yaml
  # Encryption options
  encryption:
    # Available methods: "plain", "simple_tls" and "start_tls".
    method: ""
    options:
      # The CA file to be accepted by the LDAP server. If none is provided, then
      # the default parameters from the host will be sent.
      ca_file: ""

      # Protocol version.
      ssl_version: "TLSv1_2"
```

Notice that the old `ldap.method` is getting deprecated and in later versions it
will be removed. Thus, you should use these options from now on.

## 2.3.2

- Upgraded loofah and rails-html-sanitizer to fix CVE-2018-3741

## 2.3.1

- Upgraded loofah rubygem so we avoid hitting CVE-2018-8048.

## 2.3.0

### Highlight

#### Security scanning

Portus is now able to scan security vulnerabilities on your Docker images. This
is done with different backends, where the stable one is [CoreOS
Clair](https://github.com/coreos/clair). You have to enable the desired backends
and then Portus will use them to fetch known security vulnerabilities for your
images.

**Note**: this version of Portus supports Clair v2 specifically (current
`master` branch is not supported).

You can read the [blog
post](http://port.us.org/2017/07/19/security-scanning.html) for more info.

Commits: [4cd875c2aa9f](https://github.com/SUSE/Portus/commit/4cd875c2aa9f6a5324745f98028d46a868b63e09),
[d3454cfb84f3](https://github.com/SUSE/Portus/commit/d3454cfb84f38ad4b63a729d7073108638c50341),
[f19094b98737](https://github.com/SUSE/Portus/commit/f19094b987372cca9a9247c84f11fca4131d9758).

#### Background process

One of the main issues for Portus was that sometimes it took too long to
complete certain critical tasks. For this release we have moved these tasks
into a separate *background* process. This background process resides in the
`bin/background.rb` file, and it can be enabled for containerized deployments
by setting the `PORTUS_BACKGROUND` environment variable to true.

The following tasks have been moved into this new process:

- *Security scanning*: after testing security scanning more in depth, we noticed
  that sometimes it could block Portus when showing the main page for
  repositories. This was the first task moved into this new process. Commit:
  [e0f7d53cb2b2](https://github.com/SUSE/Portus/commit/e0f7d53cb2b2cfbb4628fceb36616607d9d7dd6c).
- *Registry events*: before creating this process, we dealt with incoming
  registry events in the main Portus process. The problem with this was that
  after getting a *push* event, for example, Portus had to fetch manifests,
  which could take quite some time. This meant that Portus got blocked in some
  deployments. Now Portus will simply log the event, and then the background
  process will process it right away (by default this process will check for
  events every 2 seconds). This task can be disabled as documented
  [here](http://port.us.org/docs/background.html). Commit:
  [6a4f7d7dca60](https://github.com/SUSE/Portus/commit/6a4f7d7dca60cd6afb59b51d951b20e808690bbb).
- *Registry synchronization*: we have removed the *crono* process in favor of
  this new process. Hence, the code that was executed in previous releases by
  crono has been merged as another task of this new process. Moreover, since it
  can be quite dangerous, we have added some configuration options: it can be
  disabled; and it can be tuned with a strategy (from a riskier approach to a
  safer one). All this has been documented in [its documentation
  page](http://port.us.org/docs/background.html). Commit:
  [ced9b46a9064](https://github.com/SUSE/Portus/commit/ced9b46a9064a7c3e4374e427f3201a200db8c0a).

**Note** on deployment: this new background process has to have access to the
same database as the main Portus process.

#### Anonymous browsing

Portus will now allow anonymous users to search for public images. This is a
configurable option which is enabled by default. You can read more about this
[in the documentation](http://port.us.org/features/anonymous_browsing.html).

Commits:
[274c0908a83c](https://github.com/SUSE/Portus/commit/274c0908a83c2e4da77db191384a267a29188418),
[9d6cc25fd0b4](https://github.com/SUSE/Portus/commit/9d6cc25fd0b4478933becdf94c59386bc491c32e).

#### OAuth & OpenID Connect support

Portus' authentication logic has been extended to allow OAuth & OpenID
Connect. For OAuth you are allowed to login through the following adapters:
Google, Github, Gitlab and Bitbucket. Check the `config/config.yml` file for
more info on the exact configurable options.

Commit:
[0a5fefdd14d9](https://github.com/SUSE/Portus/commit/0a5fefdd14d99397c39c74f8900c01485135fcd4).

**Thanks a lot** to Vadim Bauer ([@Vad1mo](https://github.com/Vad1mo)) and
Andrei Kislichenko ([@andrew2net](https://github.com/andrew2net)) for working on
this!

#### API

An effort to design and implement an API for Portus has been started. This is
useful for CLI tools like [portusctl](https://github.com/openSUSE/portusctl)
among other user cases. We do not consider the API to be in a stable state, but
it is useful already. We will continue this effort in forthcoming
releases. Commits:
[2129833f27f0](https://github.com/SUSE/Portus/commit/2129833f27f05dc7a86e9783c63a4d600a7ebca5),
[28f77d3352ea](https://github.com/SUSE/Portus/commit/28f77d3352ea9e2a50716f9dba872a90fc89e1bb),
[5a9437bba42d](https://github.com/SUSE/Portus/commit/5a9437bba42d446464066fbfe187bab1d3145d3c),
[451e508bd86a](https://github.com/SUSE/Portus/commit/451e508bd86a4218d440c594398f592abafc0b4c),
[185f18e98638](https://github.com/SUSE/Portus/commit/185f18e9863819e111fcb4af4f162198462d7bd3),
[a9bdab58d150](https://github.com/SUSE/Portus/commit/a9bdab58d150d3b547f31bcee175b8c048ae10b8),
[8b42887f83a5](https://github.com/SUSE/Portus/commit/8b42887f83a5825e1101c8e47613927027b3c755),
[fbe7e8d4ef53](https://github.com/SUSE/Portus/commit/fbe7e8d4ef5370d0be8f6ba4b07a45a0b52de0a8),
[4a79f222f93b](https://github.com/SUSE/Portus/commit/4a79f222f93bbea7e42aa4f5f3c70adbe2d709c3),
[fbe7e8d4ef53](https://github.com/SUSE/Portus/commit/fbe7e8d4ef5370d0be8f6ba4b07a45a0b52de0a8).

**Thanks a lot** to Vadim Bauer ([@Vad1mo](https://github.com/Vad1mo)) and
Andrei Kislichenko ([@andrew2net](https://github.com/andrew2net)) for working on
this!

#### Puma

The deployment of Portus has been simplified as much as possible. For this
reason we have removed a *lot* of clutter on our official Docker image, and we
have embraced best practices for deploying Ruby on Rails applications. For this
reason we have set Puma as the web server for Portus.

Commits: [09b722f56221](https://github.com/SUSE/Portus/commit/09b722f5622196f7f1362990950218d20cda7061),
[9fd61ba7bae0](https://github.com/SUSE/Portus/commit/9fd61ba7bae0f8343961adb99000527d7a1d23fc),
[6a3b8ca74edb](https://github.com/SUSE/Portus/commit/6a3b8ca74edb79dc8e9ffdd5be45195de4ef9991),
[2488791f8f54](https://github.com/SUSE/Portus/commit/2488791f8f54293cdaa282494070c81c8f320ae7).

#### Production deployment examples

We provide in the source code examples that illustrate how Portus is intended to
be deployed on production. These examples reside in the `examples`
directory. Some observations:

- As stated above, set the `PORTUS_BACKGROUND` environment variable to true for
  the background process.
- You can set `RAILS_SERVE_STATIC_FILES` to true if you want Portus to serve the
  assets directly (e.g. if you don't want a load-balancer like NGinx or HAproxy
  to do this).
- Use the new `PORTUS_DB_` environment variable prefix instead of the old
  `PORTUS_PRODUCTION_` one for database options. Moreover, in the database you
  can now specify more options like `PORTUS_DB_POOL` for stating the DB pool.
- Portus will complain if you provide old environment variables like
  `PORTUS_PRODUCTION_DATABASE`, or if you forgot to specify some relevant
  environment variables for production like `PORTUS_MACHINE_FQDN_VALUE`. Commit:
  [06a405c4f5fd](https://github.com/SUSE/Portus/commit/06a405c4f5fdfbdd1d327061fa2a187ae4f6f396).

Commit:
[ba7b15ed42d0](https://github.com/SUSE/Portus/commit/ba7b15ed42d085a99856b623ec29b500c1fb7ba3).

#### Helm Chart

An official [Helm
Chart](https://github.com/kubic-project/caasp-services/tree/master/contrib/helm-charts/portus)
for deploying Portus in a Kubernetes cluster is being developed. It is expected
to be released soon after this release.

#### PostgreSQL support

Some tools like CoreOS Clair require PostgreSQL as their database. When
developing support for security scanning we noticed that it was quite redundant
to have two different databases running. For this reason, we have added
PostgreSQL support, so you can use PostgreSQL for both Portus and Clair.

Commit: [af1b8b6ca725](https://github.com/SUSE/Portus/commit/af1b8b6ca725e094ab26230126f271c59a0e8343).

#### Upgrade to Ruby 2.5

Some features required an upgrade of Ruby. Since SLE 15 and Tumbleweed will most
likely have Ruby 2.5 as their default version, we have anticipated this
move. So, now Portus is supported for Ruby 2.5. If you try to run Portus on
previous versions, it will error out during initialization (commit:
[ea02cab5c822](https://github.com/SUSE/Portus/commit/ea02cab5c8228c80a20212e39855c50d6f6ba523)).

Commits: [a2407506ff5c](https://github.com/SUSE/Portus/commit/a2407506ff5cd3dc6553378c96c972d766d9ab62),
[d86d46c9313c](https://github.com/SUSE/Portus/commit/d86d46c9313c887bb3c17df314d9aaaae390f245),
[46a5a34fda40](https://github.com/SUSE/Portus/commit/46a5a34fda402371f6082ea85e8c07e439d53800).

### Improvements and small features

- Sort tags by updated\_at date not by created\_at. Commit:
  [90ad00a32f49](https://github.com/SUSE/Portus/commit/90ad00a32f490d0aa921fe28becc7cb90341fe5d).
- Copy `docker pull` command to clipboard when clicking a tag:
  [acad5b6f442d](https://github.com/SUSE/Portus/commit/acad5b6f442d37f390f09acb7bc7ed486c346ada).
- Lots of small improvements on the UI. Commits (among others):
  [097e782ec1a3](https://github.com/SUSE/Portus/commit/097e782ec1a326f8c57bc4bef600ff5365f80266),
  [bd4d9d8db5ad](https://github.com/SUSE/Portus/commit/bd4d9d8db5ad2d6226e85df3dacaa922db554150),
  [0ae8f5e2fae6](https://github.com/SUSE/Portus/commit/0ae8f5e2fae645d7e9420701504f757d8a0b2474),
  [c891792742c0](https://github.com/SUSE/Portus/commit/c891792742c0d91d64fb49019af6446e1684ca73),
  [50d61606caa7](https://github.com/SUSE/Portus/commit/50d61606caa7b2538c877d6a924b84082524982f).
- Properly check when the DB is ready, useful for containerized
  deployments. Commit:
  [564c3cb5d35c](https://github.com/SUSE/Portus/commit/564c3cb5d35ce0e1b882c60f137fcbf8dedc1ee4).
- Make the log level configurable on production. Useful for temporarily
  debugging a production deployment. Commit:
  [db2403fd3311](https://github.com/SUSE/Portus/commit/db2403fd3311a8078bc5418f5fd635a4ec5668dc).
- Added rack-cors to prevent AJAX CORS attacks. Commit:
  [5a0402098428](https://github.com/SUSE/Portus/commit/5a04020984280e70ba79b8be5753632fe809ac13).
- Adding the X-UA-Compatible header so it works well for IE with compatibility
  mode on. Commit:
  [146076d543e8](https://github.com/SUSE/Portus/commit/146076d543e8f1618f837dd7466c5f0fdc26438d).
- Implemented timeout for requests targetting the registry. Commit:
  [9296f1eaa5bb](https://github.com/SUSE/Portus/commit/9296f1eaa5bbe796cf6891da792f9fb85f1a0ace),
  [56d2886e7f65](https://github.com/SUSE/Portus/commit/56d2886e7f651816c7acd346eb1c81fff0946980).
- Added registry validation and status. Commits:
  [a30c27071650](https://github.com/SUSE/Portus/commit/a30c27071650e5c96f5b8159622fb97fd39e2d3a),
  [d0dd2f4aeba0](https://github.com/SUSE/Portus/commit/d0dd2f4aeba06a4c4df1b37fedec347038dcb2ad).

### Fixes

- Add core-js pollyfills, so internet access is not needed. Commit:
  [02cf5212a28c](https://github.com/SUSE/Portus/commit/02cf5212a28c6d27830546a6eb14080904711b77).
- Fixed performance problems on the activities page. Commit:
  [b5fd93bd9486](https://github.com/SUSE/Portus/commit/b5fd93bd9486fc426c9ad76d9d84393b45689213).
- Fixed table pagination. Commit:
  [f05aad9e6183](https://github.com/SUSE/Portus/commit/f05aad9e61837b066b4a332cc5730dc0207ed7c8).
- Fixed some issues on activities. Commit:
  [db553f8d0bcc](https://github.com/SUSE/Portus/commit/db553f8d0bcc7b2f9eafa4a9795c846b1141c2b7).
- Honor external_hostname in token generation. Commit:
  [802bb89b0ec4](https://github.com/SUSE/Portus/commit/802bb89b0ec4eebefdd9a7d6fea513857c2483c7).
- Fixed Vagrant setup. Commit:
  [6ca35b1bc2e7](https://github.com/SUSE/Portus/commit/6ca35b1bc2e7e1d1cf124dab5d35ffa93b61a139).
- Read the TZ env variable to display dates correctly. Commit:
  [e2eed1463aaa](https://github.com/SUSE/Portus/commit/e2eed1463aaaf37a32e01cb5cdcee3e1c5722df1).
- LDAP: avoid clashes on emails. Commit:
  [1a57f0f7f95b](https://github.com/SUSE/Portus/commit/1a57f0f7f95bcb1e9dbb0c5e858ae2d7c7701f5c).
- Fixed icons spacing/positioning. Commit:
  [ab34bf9ebc5b](https://github.com/SUSE/Portus/commit/ab34bf9ebc5b36bedda53c97422d4bed1818cbef).
- Fixed team name validation behavior. Commit:
  [86e72f88b20f](https://github.com/SUSE/Portus/commit/86e72f88b20f98b20944efd215119b81a972ec7d).
- Fixed a render error on the search/index page. Commit:
  [d12306daa47b](https://github.com/SUSE/Portus/commit/d12306daa47bb78142b969650bfd306087dc1d10).
- Fixed the namespace and team name clashes. Commit:
  [eec31da471a7](https://github.com/SUSE/Portus/commit/eec31da471a7a776633cb1500b60c131f74e0636).
- Properly check SSL requirements. Commit:
  [a86ec03923f8](https://github.com/SUSE/Portus/commit/a86ec03923f821d7abb9e65ce3f5ca2206ff2b8b).
- Fixed tag name uniqueness validation. Commit:
  [83478b1911b0](https://github.com/SUSE/Portus/commit/83478b1911b00ef37fccf94eb4e7c2c3c598b4c1).
- Fixed crash on null author of a tag. Commit:
  [7f84fbc60307](https://github.com/SUSE/Portus/commit/7f84fbc6030776d03950d25be109b1a0ef42fdbd).
- Update tags by digest when scanning. Commit:
  [46065607fbc1](https://github.com/SUSE/Portus/commit/46065607fbc1b19f534fe62535e181f50579dbc6).
- Fixed crash when vulnerabilities were not found. Commit:
  [a904cef41cb2](https://github.com/SUSE/Portus/commit/a904cef41cb200f5abbb787394bcc56aa34cbe10).
- Added some checks on mailer configuration to avoid crashes later on. Commit:
  [c3ba1b50ca31](https://github.com/SUSE/Portus/commit/c3ba1b50ca3148601ec2676b1cd930f016e93337).
- Catch exceptions on password resets creation. Commit:
  [9d2ba4748693](https://github.com/SUSE/Portus/commit/9d2ba47486932307b1fe7934b20a2938aa7fff84).
- Registry Client should probe that the /v2/ path reachable and that we accept
  200 responses as well. Commit:
  [2b0bf59a2601](https://github.com/SUSE/Portus/commit/2b0bf59a260102cdd837590660bb10babe08a824).
- Upgraded jQuery to 3.x to avoid security issues. Commit:
  [0505c177f5d2](https://github.com/SUSE/Portus/commit/ec07d2240681e43cb9575454d3baa956d2eb7d38).

#### CVE

This release includes a fix for
[CVE-2017-14621](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-14621). **Thanks
a lot** Ricardo Sánchez for reporting this security issue! Commit:
[c21dfec24cfc](https://github.com/SUSE/Portus/commit/c21dfec24cfcf93f0ac06c1b9a08afad1824e41f).

### Development

- Our Rubocop rules are now as close as possible to the default style. This is
  an attempt to be closer to the decisions from the ruby community. Commit:
  [71ff67ae123b](https://github.com/SUSE/Portus/commit/71ff67ae123bb0f552732b9011de29b02a398cee).
- Update the development environment for docker-compose v2.
- Many fixes went into the test suite. Commit (among others):
  [af7d093cfdc2](https://github.com/SUSE/Portus/commit/af7d093cfdc2d421b00d0d43e2850138383c69a2).
- The configuration management has been extracted into its own gem:
  [cconfig](https://github.com/mssola/cconfig). Commits:
  [9ce311a832ae](https://github.com/SUSE/Portus/commit/9ce311a832ae83913b5b087df05bf5fd227591a8),
  [c8abbff3bd38](https://github.com/SUSE/Portus/commit/c8abbff3bd38491c9f462aa48412ac13de9e65a0).
- Introduced the `DeprecationError` exception. Commit:
  [3691273ebbd9](https://github.com/SUSE/Portus/commit/3691273ebbd9dd1179ec79a402836c170bed0573).
- Networking errors have been merged into a single point of entry. Commit:
  [944e50176c1a](https://github.com/SUSE/Portus/commit/944e50176c1a11dee40be9f3d032e9a4f1b53bde).
- Big changes on the Javascript side:
  - Turbolinks has been removed. Commit:
    [2803e2962419](https://github.com/SUSE/Portus/commit/2803e29624197665b5a95a955421dd74a95894b9).
  - We have migrated from Coffeescript to Javascript:
    [79fb15164f32](https://github.com/SUSE/Portus/commit/79fb15164f32a3da86b39e7a7b2340588830c8c9),
    [d30bc2baef16](https://github.com/SUSE/Portus/commit/d30bc2baef16693fad97d88eda88d1021d729969).
  - Javascript dependencies are now managed by yarn:
    [803829045ff3](https://github.com/SUSE/Portus/commit/803829045ff3fa53630604b972c1db1dfb8077c3).
  - Webpack is the responsible for building the assets:
    [bc56035f9c5e](https://github.com/SUSE/Portus/commit/bc56035f9c5e8ff486416cc0da9910ce52cde1cb).
  - We have introduced VueJS to bring some order into the Javascript front:
    [c3ad4bf97dbe](https://github.com/SUSE/Portus/commit/c3ad4bf97dbe2041d675ce5ef112fac8d9374956),
    [3e145dc03c79](https://github.com/SUSE/Portus/commit/3e145dc03c798b84ab4f23fb7f932cea75a136eb),
    [3dd743fd610e](https://github.com/SUSE/Portus/commit/3dd743fd610e37b266264abb08dcab6ff46a07f7).
  - We have migrated to the latest Javascript standard (EcmaScript6). This has
    involved some refactoring. See commits (among others):
    [efbff080ff82](https://github.com/SUSE/Portus/commit/efbff080ff828a504dd73455b26edae17bd9468e),
    [c8fc5823f6b7](https://github.com/SUSE/Portus/commit/c8fc5823f6b7b7d90abe6b6abcefae27013f016c),
    [dc3b00dd3dbd](https://github.com/SUSE/Portus/commit/dc3b00dd3dbd23c9adc9bbf91cf04a89d2d2fa8e),
    [ad5da31283df](https://github.com/SUSE/Portus/commit/ad5da31283df5a73a85db43d1ce29e9eb70c85a2),
    [e70e78c75b89](https://github.com/SUSE/Portus/commit/e70e78c75b89569806f27a64494b93ba41277df2),
    [a838cabc0720](https://github.com/SUSE/Portus/commit/a838cabc07204885a8fd0d24df03ca7c78db382e),
    [0428092a287f](https://github.com/SUSE/Portus/commit/0428092a287feca0cf301fdf1b7496b239816733),
    [821595bc4c52](https://github.com/SUSE/Portus/commit/821595bc4c526bbc7e1e2c1fd3de080e9e478044),
    [6e8b57f4c531](https://github.com/SUSE/Portus/commit/6e8b57f4c5316dce1cb4a96a5f46e308962cc8cf),
    [76909e9c931d](https://github.com/SUSE/Portus/commit/76909e9c931def78daa5dbf1516450d9ff9e086b),
    [0c3a003cf897](https://github.com/SUSE/Portus/commit/0c3a003cf897f58598329841bf757c0192f6f77c),
    [9c223b7a5918](https://github.com/SUSE/Portus/commit/9c223b7a5918f8eafc055d104da0a4b658e15d86),
    [f1d47a6abda7](https://github.com/SUSE/Portus/commit/f1d47a6abda7ec0a7660c1a20bca65b55018daaa),
    [1103a1ac3b55](https://github.com/SUSE/Portus/commit/1103a1ac3b55f06015e1c63b4660a750a18e1b69),
    [452ec54fc224](https://github.com/SUSE/Portus/commit/452ec54fc224da754947be2a6032d71dea4e5ad2).

### Upgrading

In this section we want to detail some things that you might want to take into
account when upgrading to 2.3:

- As explained above, Puma is now the HTTP server being used. Make sure to use
  the `PORTUS_PUMA_TLS_KEY` and the `PORTUS_PUMA_TLS_CERT` environment variables
  to point puma to the right paths for the certificates. Moreover, if you are
  not using the official Docker image, you will have to use the
  `PORTUS_PUMA_HOST` environment variable to tell Puma where to bind itself (in
  containerized deployments it will bind by default to `0.0.0.0:3000`).
- The database environment variables have changed the prefix from
  `PORTUS_PRODUCTION_` to `PORTUS_DB_`. Moreover, you will be able now to
  provide values for the following items: adapter (set it to `postgresql` for
  PostgreSQL support), port, pool and timeout. All these values are prefixed by
  `PORTUS_DB_` as well, so for example, to provide a value for the pool you need
  to set `PORTUS_DB_POOL`.

Finally, we are not running migrations automatically anymore as we used to do
before. This is now to be done by the administrator by executing (on the Portus
context in `/srv/Portus` or simply as part of a `docker exec` command):

```
$ portusctl exec rake db:migrate
```

For more details on this check the commits
[7fdfe9634180](https://github.com/SUSE/Portus/commit/7fdfe96341801b492ca0e2637fcbb0d31e54d5fc)
and
[1c4d2b6cf0e0](https://github.com/SUSE/Portus/commit/1c4d2b6cf0e09e3be770a0675a42ee23cd2f62dd).

### Deprecations

Some configuration options that were soft-deprecated in 2.2 will now raise a
`DeprecationError`. These are:

- The expiration time of the JWT token can no longer be expressed as a string
  with a format: `x.minutes`. You have to provide now an integer representing
  the minutes for the `jwt_expiration_time` configurable option. Users that have
  not touched this option since the 2.1 times will have to change this.
- The `jwt_expiration_time` option was moved to `registry.jwt_expiration_time`
  in 2.2. Now, if you continue to provide the former rather than the latter,
  you'll get a `DeprecationError` exception.

Besides this, Portus will also raise a `DeprecationError` during initialization
in the case you provided the prefix `PORTUS_PRODUCTION_` for database
configurable options instead of `PORTUS_DB_`.

Finally, `portusctl` as provided by Portus is getting deprecated in favor of
[openSUSE/portusctl](https://github.com/openSUSE/portusctl). This new
`portusctl` has been built from scratch for the following reasons:

- Since 2.3 our main focus is the support containerized deployments. Therefore,
  `portusctl`'s main task to setup the installation didn't make sense
  anymore.
- Moreover, from experience we noticed lots of corner cases where the old
  portusctl was simply not effective.
- With the introduction of the API, we wanted to re-purpose the tool to be more
  similar to tools like `kubectl` for Kubernetes. That is, a CLI interface to
  the API that administrators can use with ease.

### Packaging

Lots of issues regarding packaging were fixed. We want to highlight the
following commits:

- Do not touch the Gemfile anymore. Commit:
  [bd383fba329b](https://github.com/SUSE/Portus/commit/bd383fba329b6256fdd0bb6d1a07fa98b12aeff0).
- Change how we build dependencies. Commit:
  [0970b9903af5](https://github.com/SUSE/Portus/commit/0970b9903af5bf1668ddb48ec9915f30e9e0902e).
- Added bundled JS dependencies in the spec file. Commit:
  [f08803be6fbc](https://github.com/SUSE/Portus/commit/f08803be6fbc9d6922af38645ca0fe477c442ea7).
- Added a script to compare the gems on git and OBS. Commit:
  [291d172c12e3](https://github.com/SUSE/Portus/commit/291d172c12e3012e9857967b8f3641b2bb3dc964).

### Contributors for this release

Alexander Block, banuchka, Ben Rexin, Diokuz, Fabian Baumanis, Hart Simha, James
Maidment, Jordi Massaguer Pla, Lefnui, Maik Hinrichs, Maximilian Meister, Miquel
Sabaté Solà, Ricardo Mateus, Robin Müller, Saurabh Surana, Shammah Chancellor,
Soedarsono, Thorsten Schifferdecker, Vadim Bauer, Vítor Avelino.

... and many thanks to everyone that has contributed to Portus by leaving
comments, sending emails, submitting issues, providing feedback, etc. Thanks!

## 2.2.0

### Fixes

- Portus will now properly update the image ID when a tag has been pushed. See PR [#1054](https://github.com/SUSE/Portus/pull/1054).
- Fixed how image updates are handled. See PR [#1031](https://github.com/SUSE/Portus/pull/1031).
- Follow a consistent order in the signup form. See PR [#1119](https://github.com/SUSE/Portus/pull/1119).
- Hide passwords stored in webhooks. See PR [#1111](https://github.com/SUSE/Portus/pull/1111).
- Removed reference of missing stylesheets. See PR [#1114](https://github.com/SUSE/Portus/pull/1114).
- Fixed a bunch of issues related to activities. See PR [#1144](https://github.com/SUSE/Portus/pull/1144).
- Fixed the pre-compilation of the cover.js asset. See PR [#1157](https://github.com/SUSE/Portus/pull/1157).

### Features

- portusctl: it will show a warning when using the `--local-registry` flag but the package has not been installed. See PR [#1096](https://github.com/SUSE/Portus/pull/1096).
- Portus now supports Docker Distribution 2.5. See PR [#1068](https://github.com/SUSE/Portus/pull/1068).
- Allow docker-compose users to specify an alternative port. See PR [#1094](https://github.com/SUSE/Portus/pull/1094).

### Documentation

- Avoid the confusion on the hostnames to be used. See PR [#1056](https://github.com/SUSE/Portus/pull/1056).
- Clarified how the `--local-registry` flag works. PR [#1052](https://github.com/SUSE/Portus/pull/1052).

## 2.1.1

### Fixes

- Use the full repository name in the `portus:update_tags` task (see [005ec6503208](https://github.com/SUSE/Portus/commit/005ec6503208fa306703f55e0c8564abe12a94a2))
- Fixed a regression on assets handling (see [fc6982a4bfe2](https://github.com/SUSE/Portus/commit/fc6982a4bfe2400a00176e0981fbd112d9f9b434) and [fdb92fffb5fa](https://github.com/SUSE/Portus/commit/fdb92fffb5fa60dbef8a4dbc8e0e30732816ae58))
- Fixed the handling of the "*" action from the registry (see [6afb1ac150e6](https://github.com/SUSE/Portus/commit/6afb1ac150e6a0e3cea2cf6c03ec077ab2d59ca3))

### Improvements

- Notification messages are now more consistent (see [72e452b1fd20](https://github.com/SUSE/Portus/commit/72e452b1fd20fa1d3072a1c6fda04077e57dfcb9))
- Order users by username on the admin panel (see [e92106cd951b](https://github.com/SUSE/Portus/commit/e92106cd951b877df0b7b83fa4241b5afb4eb175))

## 2.1

### Featured

- Fixes and improvements on Docker Distribution support (see [f74eb2eac7d6](https://github.com/SUSE/Portus/commit/f74eb2eac7d6), [c8fc5ed6b337](https://github.com/SUSE/Portus/commit/c8fc5ed6b337), [95ba4d83a539](https://github.com/SUSE/Portus/commit/95ba4d83a539), [552df9caa341](https://github.com/SUSE/Portus/commit/552df9caa341), [575d51b3b7d2](https://github.com/SUSE/Portus/commit/575d51b3b7d2), [4014a7c14487](https://github.com/SUSE/Portus/commit/4014a7c14487), [e18310e6a2eb](https://github.com/SUSE/Portus/commit/e18310e6a2eb) and [7494eeed2b88](https://github.com/SUSE/Portus/commit/7494eeed2b88))
- Implemented user removal (see [d9d6e3afa224](https://github.com/SUSE/Portus/commit/d9d6e3afa224))
- Implemented the removal of images and tags (see [b63252ff07a8](https://github.com/SUSE/Portus/commit/b63252ff07a8), [10c060e246ab](https://github.com/SUSE/Portus/commit/10c060e246ab), [7ae5179ba623](https://github.com/SUSE/Portus/commit/7ae5179ba623), [85730266c9c4](https://github.com/SUSE/Portus/commit/85730266c9c4), [65a0624cd923](https://github.com/SUSE/Portus/commit/65a0624cd923), [612734339fa1](https://github.com/SUSE/Portus/commit/612734339fa1) and [c23758489c57](https://github.com/SUSE/Portus/commit/c23758489c57))
  - Also read our [blog post on image/tag removal](http://port.us.org/2016/06/20/removing-images-and-tags.html)
- Showing the image ID and the digest of docker images (see [0f290526ad97](https://github.com/SUSE/Portus/commit/0f290526ad97), [960e7599d501](https://github.com/SUSE/Portus/commit/960e7599d501), [28dae7f3fb23](https://github.com/SUSE/Portus/commit/28dae7f3fb23), [ba32d140958a](https://github.com/SUSE/Portus/commit/ba32d140958a), [0b8d1bff5b85](https://github.com/SUSE/Portus/commit/0b8d1bff5b85) and [e57232b149b5](https://github.com/SUSE/Portus/commit/e57232b149b5))
- Implemented webhook support (see [4a4a67c62d52](https://github.com/SUSE/Portus/commit/4a4a67c62d52), [702356b006d8](https://github.com/SUSE/Portus/commit/702356b006d8), [60354bb41ddc](https://github.com/SUSE/Portus/commit/60354bb41ddc), [08918c5a91d2](https://github.com/SUSE/Portus/commit/08918c5a91d2), [4b4d4c0ff70e](https://github.com/SUSE/Portus/commit/4b4d4c0ff70e) and [b3565d3ade0f](https://github.com/SUSE/Portus/commit/b3565d3ade0f))
  - Also read our [blog post on webhooks](http://port.us.org/2016/07/26/webhooks.html)
- Introduce application tokens (see [b399f90c0de5](https://github.com/SUSE/Portus/commit/b399f90c0de5) and [e38e7602f471](https://github.com/SUSE/Portus/commit/e38e7602f471))

### Improvements and small features

- Better reflect updates on Docker images (see [89b9964c0f0e](https://github.com/SUSE/Portus/commit/89b9964c0f0e))
- General improvements and fixes on the UI/UX (see [cb033f40898e](https://github.com/SUSE/Portus/commit/cb033f40898e), [e7629b758055](https://github.com/SUSE/Portus/commit/e7629b758055), [fcfd6d3548aa](https://github.com/SUSE/Portus/commit/fcfd6d3548aa), [933b86fbe9bf](https://github.com/SUSE/Portus/commit/933b86fbe9bf), [c886e9009ee0](https://github.com/SUSE/Portus/commit/c886e9009ee0), [818354d7d92c](https://github.com/SUSE/Portus/commit/818354d7d92c), [868abc65d286](https://github.com/SUSE/Portus/commit/868abc65d286), [f935d0ae79a5](https://github.com/SUSE/Portus/commit/f935d0ae79a5), [128c76febb06](https://github.com/SUSE/Portus/commit/128c76febb06), [23da71c64c7c](https://github.com/SUSE/Portus/commit/23da71c64c7c), [1ef1da2e9c70](https://github.com/SUSE/Portus/commit/1ef1da2e9c70), [78a9d81965fa](https://github.com/SUSE/Portus/commit/78a9d81965fa), [a3ffe492d134](https://github.com/SUSE/Portus/commit/a3ffe492d134))
- Allow the admin to provide extra filter options in LDAP lookup (see [99daa00d565b](https://github.com/SUSE/Portus/commit/99daa00d565b))
- Password length is no longer checked by Portus in LDAP (see [381fd61fb546](https://github.com/SUSE/Portus/commit/381fd61fb546))
- Relaxed the requirements for user names, and removed the conflicts of user names in LDAP (see [a9d5a2646d0d](https://github.com/SUSE/Portus/commit/a9d5a2646d0d) and [215c681e65c2](https://github.com/SUSE/Portus/commit/215c681e65c2))
- Introduce the `display_name` option (see [5d8c7e4bec97](https://github.com/SUSE/Portus/commit/5d8c7e4bec97))
- Allow administrators to turn off smtp authentication (see [d837160bbe3e](https://github.com/SUSE/Portus/commit/d837160bbe3e))
- Added an external hostname field to allow for events to come from other named services (see [0d58ed1fce0b](https://github.com/SUSE/Portus/commit/0d58ed1fce0b))
- Added a help section to the menu (see [40a18a04b1fe](https://github.com/SUSE/Portus/commit/40a18a04b1fe))
- Introduced more optional user restrictions (see [cddfb5924fae](https://github.com/SUSE/Portus/commit/cddfb5924fae))
- Added the registry.catalog_page option (see [de4e4f4db74e](https://github.com/SUSE/Portus/commit/de4e4f4db74e))
- Added option to disable change of visibility (see [50fb319ded81](https://github.com/SUSE/Portus/commit/50fb319ded81))
- The signup form can now be disabled, and users can be created by the admin directly (see [9bbd75cacd935f888460669d77fa47c706a5dbaf](https://github.com/SUSE/Portus/commit/9bbd75cacd935f888460669d77fa47c706a5dbaf), [79bac5c4f54b758831c867fc08b0b567418cae7d](https://github.com/SUSE/Portus/commit/79bac5c4f54b758831c867fc08b0b567418cae7d) and [fcf20d7534e2f1172713f82e06ef12abe14df046](https://github.com/SUSE/Portus/commit/fcf20d7534e2f1172713f82e06ef12abe14df046))
- Added internal policy for namespaces (see [46d1d0bc7251](https://github.com/SUSE/Portus/commit/46d1d0bc7251))
- Added namespaces and teams to search (see [f1a9698657c8](https://github.com/SUSE/Portus/commit/f1a9698657c8))
- Admins can now change the ownership of a namespace (see [e4b137a92a96](https://github.com/SUSE/Portus/commit/e4b137a92a96))
- Display the git tag, branch/commit or version when possible (see [a7bfa8dde140](https://github.com/SUSE/Portus/commit/a7bfa8dde140))
- Now logs are redirected to the standard output (see [dfc72b3d6abd](https://github.com/SUSE/Portus/commit/dfc72b3d6abd))
- Added the ability to add comments on repositories (see [4d780d93950b](https://github.com/SUSE/Portus/commit/4d780d93950b))
- Virtual/hidden teams are no longer counted for the  "number of teams"-column under admin/users (see [02722126cb92](https://github.com/SUSE/Portus/commit/02722126cb92))
- Added rake tasks for creating a registry, updating digests and showing general information (see [ec0d0063b781](https://github.com/SUSE/Portus/commit/ec0d0063b781), [4566ea0607fd](https://github.com/SUSE/Portus/commit/4566ea0607fd) and [152ce27725f7](https://github.com/SUSE/Portus/commit/152ce27725f7))
- Added man pages for portusctl ([8b4b31e1cfc3](https://github.com/SUSE/Portus/commit/8b4b31e1cfc3))
- Register more activities (see [fd97edaf6bb6](https://github.com/SUSE/Portus/commit/fd97edaf6bb6) and [bee150287604](https://github.com/SUSE/Portus/commit/bee150287604))

### Fixes

- Various fixes in LDAP support (see [b13dca7e207f](https://github.com/SUSE/Portus/commit/b13dca7e207f), [7e3feabcc2bb](https://github.com/SUSE/Portus/commit/7e3feabcc2bb) and [377a59b66c16](https://github.com/SUSE/Portus/commit/377a59b66c16))
- Discard pagination for CSV activities (see [7f120349279f](https://github.com/SUSE/Portus/commit/7f120349279f))
- Make sure that Portus admins are always team owners (see [2db13a3ae524](https://github.com/SUSE/Portus/commit/2db13a3ae524))
- User names are no longer allowed to clash with teams (see [b5b0896e78b3](https://github.com/SUSE/Portus/commit/b5b0896e78b3))
- Redirect back to accessed page on successful login (see [fed27a5dcf6a](https://github.com/SUSE/Portus/commit/fed27a5dcf6a))
- Fixes on the crono job (see [efc33be00d2e](https://github.com/SUSE/Portus/commit/efc33be00d2e) and [08d60dd91a5e](https://github.com/SUSE/Portus/commit/08d60dd91a5e))
- Multiple fixes in portusctl (see [46b5f449263f](https://github.com/SUSE/Portus/commit/46b5f449263f), [add79d790238](https://github.com/SUSE/Portus/commit/add79d790238), [2025da82f3e5](https://github.com/SUSE/Portus/commit/2025da82f3e5), [aa4997ab48a4](https://github.com/SUSE/Portus/commit/aa4997ab48a4), [f8d473430ee1](https://github.com/SUSE/Portus/commit/f8d473430ee1), [5d4eb85943ff](https://github.com/SUSE/Portus/commit/5d4eb85943ff) and [78f8f949c46e](https://github.com/SUSE/Portus/commit/78f8f949c46e))
- Multiple fixes in our RPM (see [919452db8507](https://github.com/SUSE/Portus/commit/919452db8507), [0019a65cad3b](https://github.com/SUSE/Portus/commit/0019a65cad3b), [0be925085b30](https://github.com/SUSE/Portus/commit/0be925085b30), [050d095b0887](https://github.com/SUSE/Portus/commit/050d095b0887) and [3f56c4ae4f6d](https://github.com/SUSE/Portus/commit/3f56c4ae4f6d))
- Show the "I forgot my password" link when the signup is disabled (see [2a244c8160d0](https://github.com/SUSE/Portus/commit/2a244c8160d0))

### Breaking changes

- Moved the machine FQDN from secrets.yml to config.yml (see [984671662ade](https://github.com/SUSE/Portus/commit/984671662ade))
- Deprecated the usage of "x.minutes" strings in configuration values. In future
  versions this syntax will be forbidden (see [53400181e439](https://github.com/SUSE/Portus/commit/53400181e439))

### Others

- All the improvements, features and bug fixes mentioned in the notes of 2.0.x releases.

## 2.0.5

### Improvements

- The FQDN can now be specified from the configuration too. This is meant to
  help users to transition from 2.0.x to 2.1. See
  [commit](https://github.com/SUSE/Portus/commit/f0850459cc43e9b9258e70867d5608f2ef303f3e).
- Portus is now more explicit on the allowed name format. See
[commit](https://github.com/SUSE/Portus/commit/5e1f164bacca8119fd6f9d8ec0461281914a0ecd).
- Portus is now more friendly on errors based on the namespace name. See
[commit](https://github.com/SUSE/Portus/commit/2cc3ea0803632c13ba49022f369d74dbb4e549c9).

### portusctl

- Disable automatic generation of certificates. For this, now there are two new
  flags: `--ssl-gen-self-signed-certs` and `--ssl-certs-dir <dir>`. See
  [commit](https://github.com/SUSE/Portus/commit/d34714f9a43024b1b565699bbcef22d51ea3a4f2).
- Wrap crono with the `exec` command. See
[commit](https://github.com/SUSE/Portus/commit/78f8f949c46e6cf41f058237683e2d8f5795e53e).

### Misc

- Some fixes on the generation of the RPM in OBS.

## 2.0.4

### RPM

- Automate Portus release. See [commit](https://github.com/SUSE/Portus/commit/63ce12464f54a1d2ffeb427850e20595b26bc52f).
- Rename Portus to portus on the RPM. See [commit](https://github.com/SUSE/Portus/commit/648d96c39ec6c10926b652579cf3a4c9ade69781).
- Refactored RPM. See [commit](https://github.com/SUSE/Portus/commit/378c66e0119a34a03adbc60cc489a19f9e77f4dd).
- Wrap crono with the exec command in the RPM. See [commit](https://github.com/SUSE/Portus/commit/78f8f949c46e6cf41f058237683e2d8f5795e53e).
- Require net-tools on the RPM. See [commit](https://github.com/SUSE/Portus/commit/919452db850709932bbf9e7f06a8dcdc83def931).

### portusctl

- Use the proper `make_admin` task. See [commit](https://github.com/SUSE/Portus/commit/aa4997ab48a4a15e9182ce6c48e9521501b81c97).
- Don't configure mysql in Docker. See [commit](https://github.com/SUSE/Portus/commit/2025da82f3e5550672b09e249c3cfd9a924aa64d).
- Added the portus:info task. See [commit](https://github.com/SUSE/Portus/commit/152ce27725f7896cad2dc024d29f9b33ab0fc83a).

### Improvements

- Better Sub-URI handling & configurable config-local.yml path. See [PR](https://github.com/SUSE/Portus/pull/851).
- Update ruby versions on travis. See [commit1](https://github.com/SUSE/Portus/commit/f1f34056863186d649a8412916ce33de0ac6dd78) and [commit2](https://github.com/SUSE/Portus/commit/0b34c0c56dd3458cc4cce6afba354f9659efd2ee).

### Other fixes

- Logout button and search repository are now appearing in small devices. See [commit](https://github.com/SUSE/Portus/commit/9dd5149a2561d62266124f36ab2404817aa826d5).
- Don't allow access to the hidden global team. See [commit](https://github.com/SUSE/Portus/commit/a540fd545d59bf72ef3a073d28617c87d978d44d).

## 2.0.3

- Fixed crono job when a repository could not be found. See [commit](https://github.com/SUSE/Portus/commit/120301caf665f7b637cd7ced7282461436dc1eb7).
- Fixed more issues on docker 1.10 and distribution 2.3. See
[this](https://github.com/SUSE/Portus/commit/841dbd274ed5e7efcb68105f0de13ac2954234dc)
and [this](https://github.com/SUSE/Portus/commit/75d61c6d692ebe6086ce1a16b0899fbcd8916a6e)
commits.
- Handle multiple scopes in token requests. See [commit](https://github.com/SUSE/Portus/commit/87623975690e693c8df1901ce7b255d41b530e5e).
- Add optional fields to token response. See [commit](https://github.com/SUSE/Portus/commit/f6e6e841217e9e543fcaa7af196ce5e5009ab28d).

## 2.0.2

- Fixed notification events for distribution v2.3. See [commit](https://github.com/SUSE/Portus/commit/3817d09108907fa26ddaf5ce23291a326b8b8195).

## 2.0.1

- Paginate through the catalog properly. See [commit](https://github.com/SUSE/Portus/commit/6e31712c6669df569f24daba4020f5d6607ad7db).
- Do not remove all the repos if fetching one fails. See [commit](https://github.com/SUSE/Portus/commit/5626ad9802c663718a3a31675c8383e94e9a10c3).
- Fixed SMTP setup. See [commit](https://github.com/SUSE/Portus/commit/296dabe3dd1c236409aaa31f19fb6e4a2e003c25).
- Don't let crono overflow the `log` column on the DB. See [commit](https://github.com/SUSE/Portus/commit/a0ed6d68c328fe6a9cd5e57506ba1773a96189da).
- Show the actual LDAP error on invalid login. See [commit](https://github.com/SUSE/Portus/commit/260eace6ea7a360a040e230cb9c1c72afcb1abab).
- Fixed the location of crono logs. See [commit](https://github.com/SUSE/Portus/commit/1bd45d8796def0256a1dd84a74a5b3fb4e9b702a).
- Always use relative paths. See [commit](https://github.com/SUSE/Portus/commit/93259fc7affd38f833685f565c0af1bb4d46c876).
- Set RUBYLIB when using portusctl. See [commit](https://github.com/SUSE/Portus/commit/3fdce03646386074a0982d3d642155526dea7753).
- Don't count hidden teams on the admin panel. See [commit](https://github.com/SUSE/Portus/commit/8f57252bb9118016d1098c0936fb69a708dc4d54).
- Warn developers on unsupported docker-compose versions. See [commit](https://github.com/SUSE/Portus/commit/02605b3c3eef72a4a78d8db7fda05df2eae2e7db).
- Directly invalidate LDAP logins without name and password. See [commit](https://github.com/SUSE/Portus/commit/0c0c5a1be243bd42873cb852ebb7b189df16b6fa).
- Don't show the "I forgot my password" link on LDAP. See [commit](https://github.com/SUSE/Portus/commit/1daaf1117e8d83b425373cfae45892e519fd20fa).
- Small random fixes:
  - [9f25126bd4409acf197a24b220cabc23efd7fb80](https://github.com/SUSE/Portus/commit/9f25126bd4409acf197a24b220cabc23efd7fb80)
  - [0b5c50244d02440008bd8c0cdd9094af66d9d1d9](https://github.com/SUSE/Portus/commit/0b5c50244d02440008bd8c0cdd9094af66d9d1d9)

## 2.0.0

- Portus will now check whether a Registry is reachable or not.
See PR [#437](https://github.com/SUSE/Portus/pull/437).
- Namespaces and teams have a description field. See PR
[#383](https://github.com/SUSE/Portus/pull/383).
- Second UI iteration. See pull requests:
[#445](https://github.com/SUSE/Portus/pull/445),
[#447](https://github.com/SUSE/Portus/pull/477) and
[#462](https://github.com/SUSE/Portus/pull/462).
- Repositories contained in *public* namespaces are now pullable even for
non-logged in users: PR [#468](https://github.com/SUSE/Portus/pull/468).
- SUSE RPM: provide `portusctl` tool to simplify the initial setup of Portus
- Portus will now lock users' accounts that have failed too many times on
login. See PR [#330](https://github.com/SUSE/Portus/pull/330).
- Added a mechanism of password recovery in case users forget about their
password. See PR [#325](https://github.com/SUSE/Portus/pull/325).
- Set admin user from a rake task and disable first-user is admin. See PR [#314]
  (https://github.com/SUSE/Portus/pull/314)
- Added a configuration option to specify the expiration time for JWT tokens
issued by Portus. See PR [518](https://github.com/SUSE/Portus/pull/518).
- Review requirements and provides in the RPM
PR [#277](https://github.com/SUSE/Portus/pull/277),
PR [#278](https://github.com/SUSE/Portus/pull/278),
PR [#280](https://github.com/SUSE/Portus/pull/280),
PR [#273](https://github.com/SUSE/Portus/pull/273),
- Add configure scripts for the RPM and use environment variables for
production. See:
PR [#299](https://github.com/SUSE/Portus/pull/299),
PR [#298](https://github.com/SUSE/Portus/pull/298),
PR [#281](https://github.com/SUSE/Portus/pull/281)
- Check run time requirements like ssl, secrets. See
PR [#297](https://github.com/SUSE/Portus/pull/297),
PR [#286](https://github.com/SUSE/Portus/pull/286)
- Update uglifier gem for fixing a security issue (OSVDB-126747)
PR [#292](https://github.com/SUSE/Portus/pull/292)
- Introduced LDAP support. See the initial PR [#301](https://github.com/SUSE/Portus/pull/301).
Multiple PRs followed to bring LDAP support to a proper state (see
[this](https://github.com/SUSE/Portus/pulls?utf8=%E2%9C%93&q=is%3Apr+is%3Aclosed+LDAP+created%3A%3C%3D2015-10-26+)).
- Users will not be able to create namespaces without a Registry currently
existing.
- PhantomJS is now being used in the testing infrastructure. See the following
pull requests: [#193](https://github.com/SUSE/Portus/pull/193),
[#194](https://github.com/SUSE/Portus/pull/194),
[#213](https://github.com/SUSE/Portus/pull/213),
[#216](https://github.com/SUSE/Portus/pull/216),
[#219](https://github.com/SUSE/Portus/pull/219).
- The namespace page now shows the creation date. See PR
[#229](https://github.com/SUSE/Portus/pull/229).
- There have been some fixes on the search feature. See
[#223](https://github.com/SUSE/Portus/pull/223) and
[#224](https://github.com/SUSE/Portus/pull/224).
- Hidden teams are no longer able to create namespaces. See PR
[#220](https://github.com/SUSE/Portus/pull/220).
- Added the pagination feature. See PR [#232](https://github.com/SUSE/Portus/pull/232).
- Some initial steps have been done towards running Portus inside docker. See
PR [#212](https://github.com/SUSE/Portus/pull/212).
- Added the appliance tests. See PR [#208](https://github.com/SUSE/Portus/pull/208).
- Star/Unstar repositories. See PR [#230](https://github.com/SUSE/Portus/pull/230)
and [#294](https://github.com/SUSE/Portus/pull/294).
- Now users can be enabled/disabled. See PR [#240](https://github.com/SUSE/Portus/pull/240).
- Fixed the authentication process for Docker 1.8. See PR
[#282](https://github.com/SUSE/Portus/pull/282).
- Added icons to the following tables: teams and members. See PR
[#388](https://github.com/SUSE/Portus/pull/388).
- And some fixes here and there.

## 1.0.1

- Fixed regression where namespaces could not be created from team page
    (Fixes #165)

## 1.0.0

- Initial version
