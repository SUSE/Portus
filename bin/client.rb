# This script has to be used inside of the `rails runner` command. So, for
# example, to get the results from the manifest:
#
#   $ rails runner manifest mssola/busybox:latest
#
# These are the available commands:
#   - catalog
#   - delete <name> <digest>
#   - manifest <name>[:<tag>]
#   - ping <hostname:port> [use_ssl]

require "pp"

registry = Registry.get
if registry.nil? && ARGV.first != "ping"
  puts "No registry has been configured!"
  exit 1
end

case ARGV.first
when "catalog"
  catalog = registry.client.catalog
  pp catalog
  pp "Size: #{catalog.size}"
when "delete"
  if ARGV.length == 2
    puts "You have to specify first the name, and then the digest"
    exit 1
  end
  pp registry.client.delete(ARGV[1], ARGV[2])
when "manifest"
  if ARGV.length == 1
    puts "You have to at least specify the name of the image"
    exit 1
  end

  if ARGV[1].include?(":")
    name, tag = ARGV[1].split(":")
  else
    name, tag = ARGV[1], "latest"
  end
  pp registry.client.manifest(name, tag)
when "ping"
  # No registry was found, trying to ping another one.
  if registry.nil?
    if ARGV.size == 2
      use_ssl = false
      puts "Beware: use_ssl omitted, assuming false."
    elsif ARGV.size == 3
      use_ssl = ARGV.last == "use_ssl"
      puts "Beware: use \"use_ssl\", assuming false." unless use_ssl
    else
      puts "Usage: rails runner ping hostname:port [use_ssl]"
      exit 1
    end

    registry = Registry.new(hostname: ARGV[1], use_ssl: use_ssl)
  end

  if registry.client.reachable?
    puts "Registry reachable"
  else
    puts "Error: cannot reach the registry"
  end
else
  puts "Valid commands: catalog, delete, manifest and ping."
  exit 1
end
