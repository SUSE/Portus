# Some useful constants used by portus

# This one is set by the bash wrapper we deliver with our RPM
# See packaging/suse/bin/portusctl
BUNDLER_BIN = ENV["BUNDLER_BIN"]
HOSTNAME    = `hostname -f`.chomp
