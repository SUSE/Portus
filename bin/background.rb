require "portus/db"

#
# First of all, wait until the database is up and running. This is useful in
# containerized scenarios.
#

count = 0
TIMEOUT = 90

while ::Portus::DB.ping != :ready
  if count >= TIMEOUT
    puts "Timeout reached, exiting with error. Check the logs..."
    exit 1
  end

  puts "Waiting for DB to be ready"
  sleep 5
  count += 5
end

#
# The DB is up, now let's define the different background jobs as classes.
#

require "portus/background/security_scanning"

they = [::Portus::Background::SecurityScanning.new]
values = they.map { |v| "'#{v}'" }.join(", ")
Rails.logger.info "Running: #{values}"

#
# Finally, we will loop infinitely like this:
#   1. Each background job will execute its task.
#   2. Then we will sleep until there's more work to be done.
#

SLEEP_VALUE = 10

# Loop forever executing the given tasks. It will go to sleep for spans of
# `SLEEP_VALUE` seconds, if there's nothing else to be done.
loop do
  they.each { |t| t.execute! if t.work? }
  sleep SLEEP_VALUE until they.any?(&:work?)
end

exit 0
