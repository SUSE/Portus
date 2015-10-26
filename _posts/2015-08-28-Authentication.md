---
layout: post
title:  "Authentication"
date:   2015-08-28 17:27:10
categories: documentation
---

This page is only for developers that want to get a better knowledge of how this application is able to establish authentication for private registries. If you expected to get more information on LDAP support, just go its [wiki page](https://github.com/SUSE/Portus/wiki/LDAP-support). In short, we implement the [authentication procedure](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md) from the Docker Registry HTTP API V2. In this page we are going to discuss:

1. How an unauthorized user gets rejected when he tries to perform an action.
2. How the login procedure actually works.
3. How an authorized user is able to push an image.

## Unknown user tries to push against the Registry

Imagine that you haven't logged in your private Registry. If that is the case, you won't be able to push images to it. Let's try this out. First, we setup an image to be used at our private registry:

```
vagrant@client:~> docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
registry.test.lan/busybox   latest              8c2e06607696        11 weeks ago        2.43 MB
```

In this case, we have the `busybox:latest` image, and we want to push it to our own private registry called `registry.test.lan`. So, let's push it:

```
vagrant@client:~> docker push registry.test.lan/busybox:latest
The push refers to a repository [registry.test.lan/busybox] (len: 1)
8c2e06607696: Image push failed
FATA[0000] Error pushing to registry: token auth attempt for registry http://registry.test.lan/v2/: http://portus.test.lan/v2/token?scope=repository%3Abusybox%3Apull%2Cpush&service=registry.test.lan request failed with status: 401 Unauthorized
```

The output above is what the **client** has received. That is, the server responded with a `401 Unauthorized`. Let's see what has the **registry** logged for this operation:

```
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=d9832ca4-aacf-4c1e-9c96-fae2a52adabd http.request.method=GET http.request.remoteaddr="192.168.1.4:38430"
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=error msg="error authorizing context: authorization token required" http.request.host=registry.test.lan http.request.id=d9832ca4-aacf-4c1e-9c96-fae2a52adabd http.request.method=GET http.req
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=d9832ca4-aacf-4c1e-9c96-fae2a52adabd http.request.method=GET http.request.remoteaddr="192.168.1.4:38430" ht
Jul 06 13:57:47 registry.test.lan registry[5221]: 192.168.1.4 - - [06/Jul/2015:13:57:47 +0000] "GET /v2/ HTTP/1.1" 401 114 "" "docker/1.6.2 go/go1.3.3 git-commit/7c8fca2 kernel/3.16.6-2-default os/linux arch/amd64"
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=97dc2baf-c549-45eb-b9c7-3b1e66ac80ec http.request.method=GET http.request.remoteaddr="192.168.1.4:38433"
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=error msg="error authorizing context: authorization token required" http.request.host=registry.test.lan http.request.id=97dc2baf-c549-45eb-b9c7-3b1e66ac80ec http.request.method=GET http.req
Jul 06 13:57:47 registry.test.lan registry[5221]: time="2015-07-06T13:57:47Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=97dc2baf-c549-45eb-b9c7-3b1e66ac80ec http.request.
```

If you read carefully, here it is the failure message: `msg="error authorizing context: authorization token required"`. That is, an unknown user has tried to push an image. Finally, this is the debug message as seen by the **Portus application** itself:

```
Started GET "/v2/token?scope=repository%3Abusybox%3Apull%2Cpush&service=registry.test.lan" for 192.168.1.4 at 2015-07-06 14:14:49 +0000
Cannot render console from 192.168.1.4! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::TokensController#show as JSON
  Parameters: {"scope"=>"repository:busybox:pull,push", "service"=>"registry.test.lan"}
Completed 401 Unauthorized in 0ms (ActiveRecord: 0.0ms)
```

Again, we can see that it's responding a `401 Unauthorized`, for the same reason.

## Login into the private Registry

After reading the [previous section](https://github.com/SUSE/Portus/wiki/Authentication#unknown-user-tries-to-push-against-the-registry), it's now clear that we have to login first. We do this with [Docker's login](https://docs.docker.com/reference/commandline/login/) command. In the **client**, we do it like this:

```
vagrant@client:~> docker login registry.test.lan
Username: mssola
Password:
Email: anemail@example.com
WARNING: login credentials saved in /home/vagrant/.dockercfg.
Login Succeeded
```

The Registry is now allowing this user to be logged in. This is what we can read from the logs of the **Registry**:

```
Jul 06 14:42:42 registry.test.lan registry[5221]: time="2015-07-06T14:42:42Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=98eebe9f-649d-449c-8e5e-c4380cf25b43 http.request.method=GET http.request.remoteaddr="192.168.1.4:38454"
Jul 06 14:42:42 registry.test.lan registry[5221]: time="2015-07-06T14:42:42Z" level=error msg="error authorizing context: authorization token required" http.request.host=registry.test.lan http.request.id=98eebe9f-649d-449c-8e5e-c4380cf25b43 http.request.method=GET http.req
Jul 06 14:42:42 registry.test.lan registry[5221]: time="2015-07-06T14:42:42Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=98eebe9f-649d-449c-8e5e-c4380cf25b43 http.request.method=GET http.request.remoteaddr="192.168.1.4:38454" ht
Jul 06 14:42:42 registry.test.lan registry[5221]: 192.168.1.4 - - [06/Jul/2015:14:42:42 +0000] "GET /v2/ HTTP/1.1" 401 114 "" "docker/1.6.2 go/go1.3.3 git-commit/7c8fca2 kernel/3.16.6-2-default os/linux arch/amd64"
Jul 06 14:42:43 registry.test.lan registry[5221]: time="2015-07-06T14:42:43Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=68a53cfb-d59a-41db-a3ff-24f9f7db987a http.request.method=GET http.request.remoteaddr="192.168.1.4:38456"
Jul 06 14:42:43 registry.test.lan registry[5221]: time="2015-07-06T14:42:43Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=68a53cfb-d59a-41db-a3ff-24f9f7db987a http.request.method=GET http.request.remoteaddr="192.168.1.4:38456" ht
Jul 06 14:42:43 registry.test.lan registry[5221]: 192.168.1.4 - - [06/Jul/2015:14:42:43 +0000] "GET /v2/ HTTP/1.1" 200 2 "" "docker/1.6.2 go/go1.3.3 git-commit/7c8fca2 kernel/3.16.6-2-default os/linux arch/amd64"
```

The most important snippet of this log is `msg="authorizing request"`. That is, authorization works and this user is allowed to log in. This is what the **Portus application** is reporting about this action:

```
Started GET "/v2/token?account=mssola&service=registry.test.lan" for 192.168.1.4 at 2015-07-06 14:42:42 +0000
Cannot render console from 192.168.1.4! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::TokensController#show as JSON
  Parameters: {"account"=>"mssola", "service"=>"registry.test.lan"}
  User Load (0.4ms)  SELECT  `users`.* FROM `users` WHERE `users`.`username` = 'mssola'  ORDER BY `users`.`id` ASC LIMIT 1
   (0.2ms)  BEGIN
  SQL (20.4ms)  UPDATE `users` SET `last_sign_in_at` = '2015-07-06 14:40:08', `current_sign_in_at` = '2015-07-06 14:42:43', `sign_in_count` = 6, `updated_at` = '2015-07-06 14:42:43' WHERE `users`.`id` = 1
   (4.3ms)  COMMIT
  Registry Load (0.2ms)  SELECT  `registries`.* FROM `registries` WHERE `registries`.`hostname` = 'registry.test.lan' LIMIT 1
[jwt_token] [claim] {:iss=>"portus.test.lan", :sub=>"mssola", :aud=>"registry.test.lan", :exp=>1436194063, :nbf=>1436193758, :iat=>1436193758, :jti=>"DzFnjZvagWGfUMqgFwEcuSCGhoxUFjkSLoEvbMhxMv"}
Completed 200 OK in 152ms (Views: 12.4ms | ActiveRecord: 25.5ms)
```

But wait, what are these `jwt_token`, `iss`, `aud`, etc. ? These are keys being used on the procedure of requesting an authorization token. You can read more about this [here](https://github.com/docker/distribution/blob/master/docs/spec/auth/token.md#requesting-a-token).

Moreover, the SUSE's Docker team made [this talk](https://github.com/mssola/docker-meetup-talk) in which from the slide 5 to the slide 23, we explained our journey on the implementation of this protocol. In order to see this talk, just clone it and open up the `index.html` file in a web browser.

## Pushing an image after logging in

If we have already logged in, we should be able to push images to our private registries. Imagine that we have the image `busybox:latest` and that our private registry is `registry.test.lan`. In this case, we should perform the following on the **client**:

```
vagrant@client:~> docker push registry.test.lan/busybox:latest
The push refers to a repository [registry.test.lan/busybox] (len: 1)
8c2e06607696: Image already exists
6ce2e90b0bc7: Image already exists
cf2616975b4a: Image already exists
Digest: sha256:1fa1523fe95c17712dfa51b2463592b2a9146f8e8a9037ad77829975566704ef
```

Nice! Now our image is on our private registry. Let's take a look at the logs of the **registry**:

```
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=dfbaeaa0-5f14-4332-abb4-7da00d5222b8 http.request.method=GET http.request.remoteaddr="192.168.1.4:38474"
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=error msg="error authorizing context: authorization token required" http.request.host=registry.test.lan http.request.id=dfbaeaa0-5f14-4332-abb4-7da00d5222b8 http.request.method=GET http.req
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=dfbaeaa0-5f14-4332-abb4-7da00d5222b8 http.request.method=GET http.request.remoteaddr="192.168.1.4:38474" ht
Jul 06 14:51:15 registry.test.lan registry[5221]: 192.168.1.4 - - [06/Jul/2015:14:51:15 +0000] "GET /v2/ HTTP/1.1" 401 114 "" "docker/1.6.2 go/go1.3.3 git-commit/7c8fca2 kernel/3.16.6-2-default os/linux arch/amd64"
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=debug msg="authorizing request" http.request.host=registry.test.lan http.request.id=fb31e10d-fb53-46bd-9c6a-2b4d2e5291a8 http.request.method=HEAD http.request.remoteaddr="192.168.1.4:38476"
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=debug msg=GetImageLayer auth.user.name=mssola http.request.host=registry.test.lan http.request.id=fb31e10d-fb53-46bd-9c6a-2b4d2e5291a8 http.request.method=HEAD http.request.remoteaddr="192.
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=debug msg="(*layerStore).Fetch" auth.user.name=mssola http.request.host=registry.test.lan http.request.id=fb31e10d-fb53-46bd-9c6a-2b4d2e5291a8 http.request.method=HEAD http.request.remotead
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="filesystem.GetContent(\"/docker/registry/v2/repositories/busybox/_layers/sha256/a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4/link\")" trace.duration=45.038µs t
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="filesystem.Stat(\"/docker/registry/v2/blobs/sha256/a3/a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4/data\")" trace.duration=22.498µs trace.file="/home/abuild/rp
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="filesystem.Stat(\"/docker/registry/v2/blobs/sha256/a3/a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4/data\")" trace.duration=19.287µs trace.file="/home/abuild/rp
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="filesystem.URLFor(\"/docker/registry/v2/blobs/sha256/a3/a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4/data\")" trace.duration=11.865µs trace.file="/home/abuild/
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="filesystem.ReadStream(\"/docker/registry/v2/blobs/sha256/a3/a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4/data\", 0)" trace.duration=23.428µs trace.file="/home/
Jul 06 14:51:15 registry.test.lan registry[5221]: time="2015-07-06T14:51:15Z" level=info msg="response completed" http.request.host=registry.test.lan http.request.id=fb31e10d-fb53-46bd-9c6a-2b4d2e5291a8 http.request.method=HEAD http.request.remoteaddr="192.168.1.4:38476"

(and much more...)
```

Note that the previous snippet contains just a small subset of the logged stuff from the action itself. As you can see, it first deals with the authorization part, and then goes to upload data. So what about the application? How does the application get the changes that have been performed in the Registry? Well, this is the output that we get from this action:

```
Started POST "/v2/webhooks/events" for 192.168.1.2 at 2015-07-06 14:55:58 +0000
Cannot render console from 192.168.1.2! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::EventsController#create as JSON
Completed 202 Accepted in 0ms (ActiveRecord: 0.0ms)


Started POST "/v2/webhooks/events" for 192.168.1.2 at 2015-07-06 14:55:58 +0000
Cannot render console from 192.168.1.2! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::EventsController#create as JSON
Completed 202 Accepted in 0ms (ActiveRecord: 0.0ms)


Started POST "/v2/webhooks/events" for 192.168.1.2 at 2015-07-06 14:55:58 +0000
Cannot render console from 192.168.1.2! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::EventsController#create as JSON
Completed 202 Accepted in 0ms (ActiveRecord: 0.0ms)


Started POST "/v2/webhooks/events" for 192.168.1.2 at 2015-07-06 14:55:58 +0000
Cannot render console from 192.168.1.2! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::EventsController#create as JSON
Completed 202 Accepted in 0ms (ActiveRecord: 0.0ms)


Started POST "/v2/webhooks/events" for 192.168.1.2 at 2015-07-06 14:55:58 +0000
Cannot render console from 192.168.1.2! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by Api::V2::EventsController#create as JSON
  Registry Load (0.2ms)  SELECT  `registries`.* FROM `registries` WHERE `registries`.`hostname` = 'registry.test.lan' LIMIT 1
  Namespace Load (0.2ms)  SELECT  `namespaces`.* FROM `namespaces` WHERE `namespaces`.`registry_id` = 1 AND `namespaces`.`global` = 1 LIMIT 1
  User Load (0.1ms)  SELECT  `users`.* FROM `users` WHERE `users`.`username` = 'mssola' LIMIT 1
  Repository Load (0.0ms)  SELECT  `repositories`.* FROM `repositories` WHERE `repositories`.`name` = 'busybox' AND `repositories`.`namespace_id` = 1 LIMIT 1
  Tag Load (0.2ms)  SELECT  `tags`.* FROM `tags` WHERE `tags`.`repository_id` = 1 AND `tags`.`name` = 'test'  ORDER BY `tags`.`id` ASC LIMIT 1
   (0.1ms)  BEGIN
  SQL (1.0ms)  INSERT INTO `activities` (`owner_id`, `owner_type`, `recipient_id`, `recipient_type`, `key`, `trackable_id`, `trackable_type`, `created_at`, `updated_at`) VALUES (1, 'User', 2, 'Tag', 'repository.push', 1, 'Repository', '2015-07-06 14:55:58', '2015-07-06 14:55:58')
   (56.5ms)  COMMIT
   (0.1ms)  BEGIN
  Repository Exists (0.7ms)  SELECT  1 AS one FROM `repositories` WHERE (`repositories`.`name` = BINARY 'busybox' AND `repositories`.`id` != 1 AND `repositories`.`namespace_id` = 1) LIMIT 1
   (0.1ms)  COMMIT
Completed 202 Accepted in 71ms (ActiveRecord: 59.2ms)
```

As you can see, we are using [web hooks](https://github.com/docker/distribution/blob/master/docs/notifications.md) to notify the Portus application about the recent changes.

One limitation of this is that the database could end up being inconsistent if Portus, for some reason, was unreachable when the Registry posted the newly pushed data. This is not an issue for Portus, because it takes advantage of the [Catalog API](https://github.com/docker/distribution/blob/master/docs/spec/api.md#listing-repositories). More specifically, there is a job that runs on the background that continuously fetches the catalog and then updates Portus' database if needed.
