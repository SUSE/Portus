# This script has to be used inside of the `rails runner` command. So, for
# example, to get the results from the manifest:
#
#   $ rails runner manifest mssola/busybox:latest
#
# These are the available commands:
#   - catalog
#   - delete <name> <digest>
#   - manifest <name>[:<tag>]

client = RegistryClient.new("registry.test.lan", false, "portus",
                            Rails.application.secrets.portus_password)

case ARGV.first
when "catalog"
  pp client.catalog
when "delete"
  if ARGV.length == 2
    puts "You have to specify first the name, and then the digest"
    exit 1
  end
  pp client.delete(ARGV[1], ARGV[2])
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
  pp client.manifest(name, tag)
else
  puts "Valid commands: catalog, delete, manifest."
  exit 1
end
