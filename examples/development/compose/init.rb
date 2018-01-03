# frozen_string_literal: true

#
# First of all, wait until the database is up and running. This is useful in
# containerized scenarios.
#

begin
  ::Portus::DB.wait_until(:ready) do |status|
    system("bundle exec rake db:setup") if status == :missing
  end
rescue ::Portus::DB::TimeoutReachedError => e
  Rails.logger.error "Exception: #{e.message}"
  exit 1
end

#
# The DB is up, now let's run puma
#

system("pumactl -F /srv/Portus/config/puma.rb start")
