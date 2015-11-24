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
  See PR [543](https://github.com/SUSE/Portus/pull/543). This is a first step
  into fixing the issues #283 and #179.
- Team and namespace descriptions can be written using Markdown. See pull
  requests: [#546](https://github.com/SUSE/Portus/pull/546) and
  [#531](https://github.com/SUSE/Portus/pull/531).

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
