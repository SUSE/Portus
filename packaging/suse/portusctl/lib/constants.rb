# frozen_string_literal: true

# Some useful constants used by portus

# Checks whether it's running inside of a Docker container or not
def dockerized?
  cgroup = File.read("/proc/1/cgroup")
  cgroup.include?("docker") || cgroup.include?("kubepod")
end

# This one is set by the bash wrapper we deliver with our RPM
# See packaging/suse/bin/portusctl
BUNDLER_BIN = ENV["BUNDLER_BIN"]
HOSTNAME    = (dockerized? || ENV["TRAVIS"] ? `hostname -f` : `hostnamectl --static status`).chomp
PORTUS_ROOT = ENV["PORTUS_ROOT"] ? ENV["PORTUS_ROOT"] : "/srv/Portus"
