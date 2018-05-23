# frozen_string_literal: true

require "portus/http_helpers"
require "portus/ldap/adapter"
require "portus/ldap/errors"

module Portus
  module HealthChecks
    # LDAP offers health check support for LDAP servers.
    class LDAP
      extend ::Portus::LDAP::Adapter
      extend ::Portus::LDAP::Errors

      def self.name
        "ldap"
      end

      def self.ready
        if APP_CONFIG.enabled?("ldap")
          ldap = initialized_adapter
          ldap.bind ? ["LDAP server is reachable", true] : [error_message(ldap), false]
        else
          [nil, false]
        end
      rescue Net::LDAP::Error => e
        [e.message, false]
      end
    end
  end
end
