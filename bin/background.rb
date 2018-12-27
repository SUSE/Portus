# frozen_string_literal: true

#
# First of all, wait until the database is up and running. This is useful in
# containerized scenarios.
#

::Portus::DB.wait_until(:ready)

#
# The DB is up, now let's define the different background jobs as classes.
#

require "portus/background/garbage_collector"
require "portus/background/ldap"
require "portus/background/registry"
require "portus/background/security_scanning"
require "portus/background/sync"

they = [
  ::Portus::Background::Registry.new,
  ::Portus::Background::SecurityScanning.new,
  ::Portus::Background::Sync.new,
  ::Portus::Background::GarbageCollector.new,
  ::Portus::Background::LDAP.new
].select(&:enabled?)

values = they.map { |v| "'#{v}'" }.join(", ")
Rails.logger.tagged("Initialization") { Rails.logger.info "Running: #{values}" }

#
# Between each iteration of the main loop there's going to be a sleep time. This
# sleep time is determined by the amount expected by each backend. The following
# block defines the sleep time and the maximum value. They all have to be
# divisible.
#

SLEEP_VALUE, TOP_SLEEP_VALUE = they.minmax_by(&:sleep_value).map(&:sleep_value)
they.each do |v|
  value = v.sleep_value
  next unless value % SLEEP_VALUE != 0

  Rails.logger.tagged "Initialization" do
    Rails.logger.error "Encountered '#{value}', which is not divisible by '#{SLEEP_VALUE}'"
  end
  exit 1
end
slept = 0

#
# Finally, we will loop infinitely like this:
#   1. Each background job will execute its task if needed (given the sleep time
#      and the `work?` method.
#   2. Then we will go to sleep for `SLEEP_VALUE` seconds.
#

loop do
  they.each_with_index do |t, idx|
    next if slept % t.sleep_value != 0

    t.execute! if t.work?

    if t.disable?
      Rails.logger.info "Disabling '#{t}'. Reason: #{t.disable_message}."
      they.delete_at(idx)
    end
  end

  break if ARGV.first == "--one-shot"

  sleep SLEEP_VALUE

  # Increase the sleep value by SLEEP_VALUE. If it turns out we reached out the
  # maximum value, reset it to zero, so the number gets too big.
  slept += SLEEP_VALUE
  slept = 0 if (slept % TOP_SLEEP_VALUE).zero?
end

exit 0
