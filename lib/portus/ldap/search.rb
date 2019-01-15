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
        find_user(name)&.size != 0
      end

      # Returns the entry matching the given user name.
      def find_user(name)
        return [] if APP_CONFIG.disabled?("ldap")

        configuration = ::Portus::LDAP::Configuration.new(user: { username: name })
        connection = initialized_adapter
        search_admin_or_user(connection, configuration)
      rescue ::Net::LDAP::Error => e
        Rails.logger.tagged(:ldap) { Rails.logger.warn "Connection error: #{e.message}" }
        []
      end

      # Returns the entry containing the group with the given name.
      def find_group(name)
        return [] if APP_CONFIG.disabled?("ldap")

        connection = initialized_adapter
        options    = search_options_for(filter: "(cn=#{name})", attributes: %w[member uniqueMember])
        results    = connection.search(options)
        o = connection.get_operation_result
        return results if o.code.to_i.zero?

        Rails.logger.tagged(:ldap) do
          msg = o.extended_response ? " and message '#{o.extended_response}'" : ""
          Rails.logger.debug "LDAP group failed with code #{o.code}" + msg
        end
        []
      rescue ::Net::LDAP::Error => e
        Rails.logger.tagged(:ldap) { Rails.logger.warn "Connection error: #{e.message}" }
        []
      end

      # Returns a list of usernames containing the members of the specified LDAP
      # group. If the given group was not found, then an empty array is returned.
      def find_group_and_members(name)
        results = find_group(name)
        filtered_results(results)
      end

      # Returns an array with the name of the groups where this user belongs.
      def user_groups(user)
        record = find_user(user)
        return [] if record&.size != 1

        dn = record.first.dn
        groups_from(dn, "uniqueMember") | groups_from(dn, "member")
      rescue ::Net::LDAP::Error => e
        Rails.logger.tagged(:ldap) { Rails.logger.warn "Connection error: #{e.message}" }
        []
      end

      # Returns nil if the given user was not found, otherwise it returns an
      # error message.
      def with_error_message(name)
        return if APP_CONFIG.disabled?("ldap")
        return unless exists?(name)

        "The username '#{name}' already exists on the LDAP server. Use " \
        "another name to avoid name collision"
      end

      protected

      # Returns a list with the name of the groups where the given dn is set as
      # a `uniqueMember`. It may raise a ::Net::LDAP::Error if the connection
      # with the LDAP server failed for whatever reason.
      def groups_from(dn, key)
        connection = initialized_adapter

        options = search_options_for(filter: "(&(cn=*)(#{key}=#{dn}))", attributes: %w[cn])
        results = connection.search(options)
        unless connection.get_operation_result.code.to_i.zero?
          Rails.logger.tagged(:ldap) do
            Rails.logger.debug "Could not find #{dn} based on '#{key}'"
          end
        end
        return [] if results.blank?

        results.map do |r|
          cn = r.dn.split(",").first
          cn.split("=", 2).last
        end
      end

      # Returns a hash with the search options given some parameters.
      def search_options_for(filter:, attributes:)
        {}.tap do |opts|
          group_base        = APP_CONFIG["ldap"]["group_base"]
          opts[:base]       = group_base if group_base.present?
          opts[:filter]     = Net::LDAP::Filter.construct(filter)
          opts[:attributes] = attributes
        end
      end

      # Returns the given LDAP results (uniquemember) and transforms the given
      # list so it contains only the relevant information (i.e. user names).
      def filtered_results(results)
        return [] if results.blank?

        members = results.first[:uniquemember]
        members = results.first[:member] if members.blank?
        members.map do |r|
          uid = r.split(",").first
          uid.split("=", 2).last
        end
      end
    end
  end
end
