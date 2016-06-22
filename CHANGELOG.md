## Upcoming Version

- The signup form can be disabled via a configuration option. See PR
[#569](https://github.com/SUSE/Portus/pull/569),
[#594](https://github.com/SUSE/Portus/pull/594),
[#543](https://github.com/SUSE/Portus/pull/543) and
[#568](https://github.com/SUSE/Portus/pull/568).
- Users will be offered in an autocompletion widget when adding a new team
  member. See PR [#547](https://github.com/SUSE/Portus/pull/547).
- Portus now also tracks the digest of pushed images.
  See PR [#556](https://github.com/SUSE/Portus/pull/556). This is a first step
  into fixing the issue #512.
- Teams can be renamed. See PR [#536](https://github.com/SUSE/Portus/pull/536).
- Users can be created from the admin page.
  See PR [#543](https://github.com/SUSE/Portus/pull/543). This is a first step
  into fixing the issues #283 and #179.
- Team and namespace descriptions can be written using Markdown. See pull
  requests: [#546](https://github.com/SUSE/Portus/pull/546) and
  [#531](https://github.com/SUSE/Portus/pull/531).
- Team members can comment on repositories. See pull request: [#538](https://github.com/SUSE/Portus/pull/583)
- Users can create security tokens to use instead of their credentials. See pull request: [#625](https://github.com/SUSE/Portus/pull/625)
- Added the `portus:info` rake task. See PR [#799](https://github.com/SUSE/Portus/pull/799).
- Allow admins to provide extra filter options for LDAP. See PR[#639](https://github.com/SUSE/Portus/pull/639).

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
