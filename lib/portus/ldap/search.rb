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
        return if APP_CONFIG.disabled?("ldap")

        configuration = ::Portus::LDAP::Configuration.new(user: { username: name })
        connection = initialized_adapter
        search_admin_or_user(connection, configuration)
      end

      # Returns a list of usernames containing the members of the specified LDAP
      # group. If the given group was not found, then an empty array is returned.
      def find_group_and_members(name)
        return [] if APP_CONFIG.disabled?("ldap")

        connection = initialized_adapter
        results = connection.search(group_search_options(name))
        return filtered_results(results) if results.present?

        Rails.logger.tagged(:ldap) do
          o = ldap.get_operation_result
          msg = o.extended_response ? " and message '#{o.extended_response}'" : ""
          Rails.logger.info "LDAP group failed with code #{o.code}" + msg
        end
        []
      end

      # Returns an array with the name of the groups where this user belongs.
      def user_groups(user)
        record = find_user(user)
        return [] if record&.size != 1

        groups_from_unique_member(record.first.dn)
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
      # a `uniqueMember`.
      def groups_from_unique_member(dn)
        connection = initialized_adapter

        options = search_options_for(filter: "(&(cn=*)(uniqueMember=#{dn}))", attributes: %w[cn])
        results = connection.search(options)
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

      # Returns the search options for the given team name.
      # TODO: see search_options_for
      def group_search_options(name)
        {}.tap do |opts|
          group_base        = APP_CONFIG["ldap"]["group_base"]
          opts[:base]       = group_base if group_base.present?
          opts[:filter]     = Net::LDAP::Filter.eq("cn", name)
          opts[:attributes] = %w[uniquemember]
        end
      end

      # Returns the given LDAP results (uniquemember) and transforms the given
      # list so it contains only the relevant information (i.e. user names).
      def filtered_results(results)
        results.first[:uniquemember].map do |r|
          uid = r.split(",").first
          uid.split("=", 2).last
        end
      end
    end
  end
end
