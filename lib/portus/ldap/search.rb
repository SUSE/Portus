# frozen_string_literal: true

require "portus/ldap/adapter"
require "portus/ldap/configuration"
require "portus/ldap/connection"

module Portus
  module LDAP
    # Search implements methods that only perform search actions towards the
    # configured LDAP server.
    class Search
      include ::Portus::LDAP::Adapter
      include ::Portus::LDAP::Connection

      # Returns true if the given name exists on the LDAP server, false
      # otherwise.
      def exists?(name)
        return if APP_CONFIG.disabled?("ldap")

        configuration = ::Portus::LDAP::Configuration.new(user: { username: name })
        connection = initialized_adapter
        record = search_admin_or_user(connection, configuration)
        record&.size != 0
      end

      # Returns nil if the given user was not found, otherwise it returns an
      # error message.
      def with_error_message(name)
        return if APP_CONFIG.disabled?("ldap")
        return unless exists?(name)

        "The username '#{name}' already exists on the LDAP server. Use " \
        "another name to avoid name collision"
      end
    end
  end
end
