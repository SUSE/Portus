require "portus/db"

count = 0
TIMEOUT = 90

while Portus.database_exists? != "DB_READY"
  if count >= TIMEOUT
    puts "Timeout reached, exiting with error. Check the logs..."
    exit 1
  end

  puts "Waiting for DB to be ready"
  sleep 5
  count += 5
end

loop do
  RegistryEvent.where(handled: RegistryEvent.statuses[:fresh]).find_each do |e|
    data = JSON.parse(e.data)
    RegistryEvent.handle!(data)
  end

  sleep 5 if RegistryEvent.where(handled: RegistryEvent.statuses[:fresh]).empty?
end

exit 0
