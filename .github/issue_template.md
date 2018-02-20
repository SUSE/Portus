### Description

Check out the `CONTRIBUTING.md` file for some considerations before submitting a
new issue.

### Steps to reproduce

1. First I did this...
2. Then that...
3. And this happened!

- **Expected behavior**: I expected this to happen!
- **Actual behavior**: But this happened...

Providing logs of the moment when the issue has happened would also be
useful. If you are in production, you might want to set the `PORTUS_LOG_LEVEL`
to `debug` to get a more verbose log.

### Deployment information

**Deployment method**: how have you deployed Portus? Are you using one of the
[examples](https://github.com/SUSE/Portus/tree/master/examples) as a base? If
possible, could you paste your configuration? (don't forget to strip passwords
or other sensitive data!)

**Configuration**:

You can get this information like this:

- In bare metal execute: `bundle exec rake portus:info`.
- In a container:
  - Using the development `docker-compose.yml` file: `docker exec -it <container-id> bundle exec rake portus:info`.
  - Using the [production image](https://hub.docker.com/r/opensuse/portus/): `docker exec -it <container-id> portusctl exec rake portus:info`.

```yml
CONFIG HERE
```

**Portus version**: with commit if possible. You can get this info too with the
above commands.
