# frozen_string_literal: true

require "portus/ldap/adapter"

module Portus
  module LDAP
    # Connection holds a set of methods which are responsible for binding to the
    # LDAP server by considering the given configuration.
    module Connection
      # Bind to the LDAP server with the given configuration by using the given
      # connection.
      #
      # On success, it will return two values: the entry and a boolean value
      # instructing whether this user should be considered an admin or not. On
      # failure, it will log the error, call `fail!` and return only a falsey
      # value.
      #
      # It will raise a ::Portus::LDAP::Error exception if the given
      # configuration is incomplete (e.g. missing parameters) or LDAP is
      # disabled. It might also raise a Net::LDAP::Error since in the end this
      # method calls `#bind_as` from Net::LDAP.
      def bind_as(connection, cfg)
        raise ::Portus::LDAP::Error, "LDAP is disabled" unless cfg.enabled?
        raise ::Portus::LDAP::Error, "Some parameters are missing" unless cfg.initialized?

        res, admin = bind_admin_or_user(connection, cfg)
        binding_failed!(connection, cfg.username) unless res
        [res, admin]
      end

      protected

      # Tries to fallback into the DB, otherwise it logs an error and fails.
      def binding_failed!(connection, username)
        return if User.exists?(username: username)

        logged_error_message!(connection, username)
      end

      # If `ldap.admin_base` is enabled, then it tries to bind first on the
      # admin route, and then as a regular user. Otherwise, it tries to bind
      # considering only the `ldap.base` as a base if provided.
      #
      # Returns two values: first of all the entry, and then a boolean value
      # specifying whether we should consider this user as an admin or not.
      def bind_admin_or_user(connection, cfg)
        if APP_CONFIG["ldap"]["admin_base"].present?
          res = connection.bind_as(bind_options(cfg, admin: true))
          return [res, true] if res
        end

        [connection.bind_as(bind_options(cfg, admin: false)), false]
      end

      # Performs a search operation by first assuming that it's an admin user,
      # and then assuming that it's a regular one.
      def search_admin_or_user(connection, cfg)
        if APP_CONFIG["ldap"]["admin_base"].present?
          record = connection.search(search_options(cfg, admin: true))
          return record if record&.size == 1
        end

        connection.search(search_options(cfg, admin: false))
      end

      # Returns a hash with the search options with the given configuration with
      # the password also in it.
      def bind_options(cfg, admin:)
        search_options(cfg, admin: admin).merge(password: cfg.password)
      end

      # Returns a hash with the search options to be applied. The base to be
      # taken into consideration will depend on the `admin` parameter.
      def search_options(cfg, admin:)
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
          if admin
            opts[:base] = APP_CONFIG["ldap"]["admin_base"]
          elsif APP_CONFIG["ldap"]["base"].present?
            opts[:base] = APP_CONFIG["ldap"]["base"]
          end
        end
      end
    end
  end
end
