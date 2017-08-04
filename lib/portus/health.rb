require "portus/health_checks/db"
require "portus/health_checks/registry"
require "portus/health_checks/clair"

module Portus
  # Health contains methods for checking the status of the different relevant
  # components.
  class Health
    CHECKS = [
      Portus::HealthChecks::DB,
      Portus::HealthChecks::Registry,
      Portus::HealthChecks::Clair
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
