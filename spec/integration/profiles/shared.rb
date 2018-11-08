# frozen_string_literal: true

# It truncates the DB. Use this always on profiles.
def clean_db!
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0")
  ActiveRecord::Base.connection.data_sources.each do |table|
    next if table == "schema_migrations"

    ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
  end
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1")
end

# Creates a registry that works with the current setup, and it creates the
# Portus special user.
def create_registry!
  # Hostname configurable so some tests can check wrong hostnames.
  hostname = ENV["PORTUS_INTEGRATION_HOSTNAME"] || "172.17.0.1:5000"
  Registry.create!(name: "registry", hostname: hostname, use_ssl: false)
  ENV["PORTUS_INTEGRATION_HOSTNAME"] = nil

  User.create_portus_user!
end
