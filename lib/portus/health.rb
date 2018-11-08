# frozen_string_literal: true

require "portus/health_checks/db"
require "portus/health_checks/clair"
require "portus/health_checks/ldap"
require "portus/health_checks/registry"

module Portus
  # Health contains methods for checking the status of the different relevant
  # components.
  class Health
    CHECKS = [
      ::Portus::HealthChecks::DB,
      ::Portus::HealthChecks::Clair,
      ::Portus::HealthChecks::LDAP,
      ::Portus::HealthChecks::Registry
    ].freeze

    # The check class method returns a two-sized array: the first element is a
    # hash with the result of each component, and the last element is a boolean
    # containing the overall result.
    def self.check
      success = true
      results = CHECKS.map do |c|
        ready, s = c.ready
        next if ready.nil?

        success = false unless s
        [c.name, { msg: ready, success: s }]
      end

      [results.compact.to_h, success]
    end
  end
end
