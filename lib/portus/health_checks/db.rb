# frozen_string_literal: true

require "portus/db"

module Portus
  module HealthChecks
    # DB offers health check support for the database.
    class DB
      def self.name
        "database"
      end

      def self.ready
        case ::Portus::DB.ping
        when :ready
          ["database is up-to-date", true]
        when :empty
          ["database is initializing", false]
        when :missing
          ["database has not been created", false]
        when :down
          ["cannot connect to database", false]
        else
          ["unknown error", false]
        end
      end
    end
  end
end
