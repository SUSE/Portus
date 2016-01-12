---
title: NGinx + Thin/Puma
order: 3
layout: post
---

As you probably have noticed, there is a Passenger configuration bundled with
the rpm that is being built for Portus. That is, the production setup in which
the Portus developers are continuously testing is with Apache in place. This
doesn't mean, however, that Portus cannot run with other setups. In this page,
an example will be provided where NGinx will be used to handle SSL for
Portus.

## The Registry

First of all, in this setup the private registry does not run behind NGinx.
Moreover, for simplicity's sake, SSL keys/certificates are the same for both
Portus and the registry, and all the SSL configuration has been placed inside
of the `/etc/nginx/ssl` directory. With this in mind, our private registry
has been configured like this:

{% highlight yaml %}
version: 0.1
loglevel: debug
storage:
  filesystem:
    rootdirectory: /var/lib/docker-registry
  delete:
    enabled: true
http:
  addr: :5000
  tls:
    certificate: /etc/nginx/ssl/registry.example.com.crt
    key: /etc/nginx/ssl/registry.example.com.key
auth:
  token:
    realm: https://registry.example.com/v2/token
    service: registry.example.com:5000
    issuer: registry.example.com
    rootcertbundle: /etc/nginx/ssl/registry.example.com.crt
notifications:
  endpoints:
    - name: portus
      url:
      https://registry.example.com/v2/webhooks/events
      timeout: 500ms
      threshold: 5
      backoff: 1s
{% endhighlight %}

As you can see, the registry follows a pretty straight-forward configuration.
Some common pitfalls are to use wrong certificates/keys, or to not write
hostname/ports properly. Just double-check that everything is as it should
be in your case.

## NGinx

It's common practice to provide a global configuration in the form of the
`/etc/nginx/nginx.conf` file, and then provide specific configurations for all
the running sites inside of the `/etc/nginx/sites-enabled` directory. We've
done exactly this for this setup. More precisely, this is how the `nginx.conf`
file looks like:

    user http http;
    worker_processes 2;

    events {
      worker_connections 1024;
    }

    http {
      include       mime.types;
      default_type  application/octet-stream;
      charset       UTF-8;

      # Some basic config.
      server_tokens off;
      sendfile      on;
      tcp_nopush    on;
      tcp_nodelay   on;

      # On timeouts.
      keepalive_timeout     65;
      client_header_timeout 240;
      client_body_timeout   240;
      fastcgi_read_timeout  249;
      reset_timedout_connection on;

      # And finally include the enabled sites.
      include /etc/nginx/sites-enabled/*;
    }

Remember that this is just an example, you should tweak configuration values
like `user`, `worker_processes`, etc. depending on your requirements.  Inside
of the `/etc/nginx/sites-enabled` directory we have the following configuration:

    # We use Thin with two listening sockets. This way we avoid problems as the one
    # described in: https://github.com/SUSE/Portus/issues/373.
    upstream portus {
      server unix://PORTUS_LOCATION/tmp/sockets/thin.0.sock max_fails=1 fail_timeout=15s;
      server unix://PORTUS_LOCATION/tmp/sockets/thin.1.sock max_fails=1 fail_timeout=15s;
    }

    server {
      listen 443 ssl spdy;
      server_name registry.example.com;

      ##
      # SSL

      ssl on;

      # Certificates
      ssl_certificate /etc/nginx/ssl/registry.example.com.crt;
      ssl_certificate_key /etc/nginx/ssl/registry.example.com.key;

      # Enable session resumption to improve https performance
      #
      # http://vincent.bernat.im/en/blog/2011-ssl-session-reuse-rfc5077.html
      ssl_session_cache shared:SSL:10m;
      ssl_session_timeout 10m;

      # Enables server-side protection from BEAST attacks
      # http://blog.ivanristic.com/2013/09/is-beast-still-a-threat.html
      ssl_prefer_server_ciphers on;

      # Disable SSLv3 (enabled by default since nginx 0.8.19)
      # since it's less secure than TLS
      # http://en.wikipedia.org/wiki/Secure_Sockets_Layer#SSL_3.0
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

      # Ciphers chosen for forward secrecy and compatibility.
      #
      # http://blog.ivanristic.com/2013/08/configuring-apache-nginx-and-openssl-for-forward-secrecy.html
      ssl_ciphers 'EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS';

      # SPDY config
      spdy_headers_comp 1;

      ##
      # Log

      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;

      ##
      # Docker-specific stuff.

      proxy_set_header Host $http_host;   # required for Docker client sake
      proxy_set_header X-Forwarded-Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Scheme $scheme;

      # disable any limits to avoid HTTP 413 for large image uploads
      client_max_body_size 0;

      # required to avoid HTTP 411: see Issue #1486
      # (https://github.com/docker/docker/issues/1486)
      chunked_transfer_encoding on;

      ##
      # Custom headers.

      # Adding HSTS[1] (HTTP Strict Transport Security) to avoid SSL stripping[2].
      #
      # [1] https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security
      # [2] https://en.wikipedia.org/wiki/SSL_stripping#SSL_stripping
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

      # Don't allow the browser to render the page inside a frame or iframe
      # and avoid Clickjacking. More in the following link:
      #
      # https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options
      add_header X-Frame-Options DENY;

      # Disable content-type sniffing on some browsers.
      add_header X-Content-Type-Options nosniff;

      # This header enables the Cross-site scripting (XSS) filter built into
      # most recent web browsers. It's usually enabled by default anyway, so the
      # role of this header is to re-enable the filter for this particular
      # website if it was disabled by the user.
      add_header X-XSS-Protection "1; mode=block";

      ##
      # Location

      location / {
        proxy_pass http://portus;
        proxy_read_timeout 900;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering on;
        auth_basic off;
      }
    }

There's a lot to review here. First and foremost, take a look at the `upstream
portus` configuration. In this setup we use Thin to run Portus. However, it's
known that at least two sockets have to be used for this kind of setup to work
(take a look at the issue [#373](https://github.com/SUSE/Portus/issues/373) for
 more information). In this case, we just use two Unix sockets in Thin to avoid
this problem. The rest of the configuration is just SSL specifics and some
Docker specific stuff. Again, this is just an example, tweak it as much as it's
required for you.

## Thin

As discussed previously, in this example we are using Thin to run Portus
itself. In order to tell Thin to create the sockets as expected by our NGinx
configuration, we have come up with the following configuration file:

{% highlight yaml %}
servers: 2
onebyone: true
socket: tmp/sockets/thin.sock
{% endhighlight %}

This configuration should already handle the fact that we require two sockets.
This can be executed by performing:

    $ thin start -C config/thin.yml

And hopefully that is all. Enjoy!

## Puma

Alternatively, you can use Puma. In order to do this, you should change the
`upstream` section of the NGinx configuration to:

    upstream portus {
        server unix:///PORTUS_LOCATION/tmp/sockets/puma.sock max_fails=1 fail_timeout=15s;
    }

And then, a Puma configuration that works quite nicely is:

{% highlight ruby %}
#!/usr/bin/env puma

# Workers and connections.
threads 1, 4
workers 3
bind "unix://#{File.join(Dir.pwd, "tmp/sockets/puma.sock")}"

# Daemon config. It will save the pid to tmp/pids/puma.pid. All the output
# from both stdout and stderr will be redirected to logs/puma.log.
log_file = File.join(Dir.pwd, "log/puma.log")
stdout_redirect log_file, log_file, true
pidfile File.join(Dir.pwd, "tmp/pids/puma.pid")
daemonize

# Copy on write.
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
{% endhighlight %}

Just be sure to understand the configuration above and tweak it to your own
needs (note that the config above assumes that you're calling Puma from the
root of the project). Restart NGinx and start your Puma instances to get
Portus up and running.
