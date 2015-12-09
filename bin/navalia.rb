# This script has to be used inside of the `rails runner` command. So, for
# example, to get the status of a build:
#
#   $ rails runner bin/navalia.rb status XXXXX
#
#   Where XXXX is the ID of the build returned by a previous build command
#
# These are the available commands:
#   - status <build_id>
#   - delete <build_id>
#   - build <url> <registry_hostname> <image_id>
#   - ping <hostname:port>

hostname = APP_CONFIG["navalia"]["address"]
puts "Using hostname #{hostname}"

case ARGV.first
when "status"
  if ARGV.size != 2
    puts "Usage: bundle exec rails runner bin/navalia status <id>"
    exit 1
  end
  ids = [ARGV[1]]
  n = Portus::NavaliaClient.new(hostname)
  puts "Calling status on #{ids}"
  s = n.status(ids)
  puts "Status #{s.body}"
when "delete"
  if ARGV.size != 2
    puts "Usage: bundle exec rails runner bin/navalia delete <id>"
    exit 1
  end
  ids = [ARGV[1]]
  n = Portus::NavaliaClient.new(hostname)
  puts "Calling delete on #{ids}"
  n.delete(ids)
when "build"
  if ARGV.size != 4
    puts "Usage: bundle exec rails runner bin/navalia build <url> <registry_hostname> <image_id>"
    exit 1
  end
  url = ARGV[1]
  registry_hostname = ARGV[2]
  image_id = ARGV[3]
  puts "Triggering build on url #{url}, registry #{registry_hostname} for image #{image_id}"
  n = Portus::NavaliaClient.new(hostname)
  resp = n.build(url, registry_hostname, image_id)
  puts "ID: #{resp.body}"
when "ping"
  puts "ping"
  hostname = ARGV[1] if ARGV.size == 2
  puts "Pinging #{hostname} ..."
  if Portus::NavaliaClient.new(hostname).reachable?
    puts "Navalia reachable at #{hostname}."
  else
    puts "Error: navalia is not reachable at #{hostname}."
  end

else
  puts "Valid commands: status, delete, build and ping."
end
