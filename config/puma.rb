#!/usr/bin/env puma

# Workers and connections.
threads 1, ENV["PORTUS_PUMA_MAX_THREADS"] || 1
workers ENV["PORTUS_PUMA_WORKERS"] || 1

# If specified, use the given host:port. Otherwise, we will use a local
# deployment through a UNIX socket.
if ENV["PORTUS_PUMA_HOST"]
  bind "tcp://#{ENV["PORTUS_PUMA_HOST"]}"
else
  bind "unix://#{File.join(Dir.pwd, "tmp/sockets/puma.sock")}"
end

# Daemon config. It will save the pid to tmp/pids/puma.pid. All the output
# from both stdout and stderr will be redirected to logs/puma.log.
#
# You should not set this when running in a Docker container.
if ENV["PORTUS_PUMA_DAEMONIZE"] == "yes"
  log_file = File.join(Dir.pwd, "log/puma.log")
  stdout_redirect log_file, log_file, true
  pidfile File.join(Dir.pwd, "tmp/pids/puma.pid")
  daemonize
end

# Copy on write.
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
