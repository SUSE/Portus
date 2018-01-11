# frozen_string_literal: true

module Portus
  # The DB module has useful methods for DB purposes.
  module DB
    WAIT_TIMEOUT  = 90
    WAIT_INTERVAL = 5

    # Pings the DB and returns a proper symbol depending on the situation:
    #   * ready: the database has been created and initialized.
    #   * empty: the database has been created but has not been initialized.
    #   * missing: the database has not been created.
    #   * down: cannot connect to the database.
    #   * unknown: there has been an unexpected error.
    def self.ping
      ::Portus::DB.migrations? ? :ready : :empty
    rescue ActiveRecord::NoDatabaseError
      :missing
    rescue Mysql2::Error
      :down
    rescue StandardError
      :unknown
    end

    # Waits until the passed status is reached. Every `WAIT_INTERVAL` seconds
    # it notifies the given block with the current status at the moment. After
    # `WAIT_TIMEOUT` seconds, it raises a `TimeoutReachedError` exception.
    #
    # The possible status that can be passed are listed in the `self.ping`
    # function description.
    def self.wait_until(status)
      count = 0

      while (current_status = ::Portus::DB.ping) != status
        if count >= WAIT_TIMEOUT
          Rails.logger.tagged("Database") do
            Rails.logger.error "Timeout reached, exiting with error. Check the logs..."
          end

          raise ::Portus::DB::TimeoutReachedError, "Timeout reached for '#{status}' status"
        end

        Rails.logger.tagged("Database") { Rails.logger.error "Not ready yet. Waiting..." }
        sleep WAIT_INTERVAL
        count += 5

        yield current_status if block_given?
      end
    end

    # Returns true if the migrations have been run. The implementation is pretty
    # trivial, but this gives us a nice way to test this module.
    def self.migrations?
      ActiveRecord::Base.connection
      return unless ActiveRecord::Base.connection.table_exists? "schema_migrations"

      # If db:migrate:status does not return a migration as "down", then all
      # migrations are up and ready.
      !`#{bundle} exec rake db:migrate:status`.include?("down")
    end

    # Returns the proper bundle command. This is important because is some cases
    # (e.g. RPM or containerized production deployment), the `bundle` command
    # might not be in an executable path.
    def self.bundle
      exec = nil
      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        x = File.join(path, "bundle")
        if File.executable?(x) && !File.directory?(x)
          exec = x
          break
        end
      end

      exec ? "bundle" : "portusctl"
    end

    # Returns true if the given configured adapter is MariaDB.
    def self.mysql?
      adapter.blank? || adapter == "mysql2"
    end

    # Returns the string of the currently configured backend, or nil if nothing
    # was set.
    def self.adapter
      ENV["PORTUS_DB_ADAPTER"]
    end

    private_class_method :adapter

    # Raised if any timeout reached
    class TimeoutReachedError < RuntimeError; end
  end
end
