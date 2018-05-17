# frozen_string_literal: true

module Portus
  module LDAP
    # Configuration holds the parameters that are passed between the different
    # components of LDAP support.
    class Configuration
      attr_reader :username, :password

      def initialize(params)
        @enabled  = APP_CONFIG.enabled?("ldap") && params.fetch(:account, "") != "portus"
        @username = params.fetch(:user, {})[:username]
        @password = params.fetch(:user, {})[:password]
      end

      # Returns true if LDAP is enabled given the passed parameters during
      # initialization, false otherwise.
      def enabled?
        @enabled
      end

      # Returns true if the given parameters have initialized all the required
      # fields, false otherwise.
      def initialized?
        @username.present? && @password.present?
      end
    end
  end
end
