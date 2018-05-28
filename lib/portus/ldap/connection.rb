# frozen_string_literal: true

require "portus/ldap/adapter"

module Portus
  module LDAP
    # Connection holds a set of methods which are responsible for binding to the
    # LDAP server by considering the given configuration.
    module Connection
      # Bind to the LDAP server with the given configuration by using the given
      # connection. Returns true if everything went alright, false otherwise. On
      # failure it will also log the error and call `fail!`.
      #
      # It will raise a ::Portus::LDAP::Error exception if the given
      # configuration is incomplete (e.g. missing parameters) or LDAP is
      # disabled. It might also raise a Net::LDAP::Error since in the end this
      # method calls `#bind_as` from Net::LDAP.
      def bind_as(connection, cfg)
        raise ::Portus::LDAP::Error, "LDAP is disabled" unless cfg.enabled?
        raise ::Portus::LDAP::Error, "Some parameters are missing" unless cfg.initialized?

        res = connection.bind_as(bind_options(cfg))
        logged_error_message!(connection, cfg.username) unless res
        res
      end

      protected

      # Returns a hash with the search options with the given configuration with
      # the password also in it.
      def bind_options(cfg)
        search_options(cfg).merge(password: cfg.password)
      end

      # Returns a hash with the search options to be applied.
      def search_options(cfg)
        # Filter for uid.
        uid = APP_CONFIG["ldap"]["uid"]
        filter = Net::LDAP::Filter.equals(uid, cfg.username)

        # Possibly add an optional filter.
        provided = APP_CONFIG["ldap"]["filter"]
        if provided.present?
          provided_filter = Net::LDAP::Filter.construct(provided)
          filter = Net::LDAP::Filter.join(filter, provided_filter)
        end

        {}.tap do |opts|
          opts[:filter] = filter
          opts[:base]   = APP_CONFIG["ldap"]["base"] unless APP_CONFIG["ldap"]["base"].empty?
        end
      end
    end
  end
end
