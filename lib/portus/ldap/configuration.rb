# frozen_string_literal: true

module Portus
  module LDAP
    # Configuration holds the parameters that are passed between the different
    # components of LDAP support.
    class Configuration
      attr_reader :username, :password, :reason

      def initialize(params)
        @username = params.fetch(:user, {})[:username]
        @password = params.fetch(:user, {})[:password]
        @soft     = true
        @enabled  = check_account(params.fetch(:account, "")) && APP_CONFIG.enabled?("ldap")
      end

      # Returns true if LDAP is enabled given the passed parameters during
      # initialization, false otherwise.
      def enabled?
        @enabled
      end

      # Returns true if the existing error is a soft one (caller can still try
      # with other authenticatables) or a hard one (caller should stop the
      # authenticatable chain right now). This is only useful if we know there's
      # been an error.
      def soft?
        @soft
      end

      # Returns true if the given parameters have initialized all the required
      # fields, false otherwise.
      def initialized?
        @username.present? && @password.present?
      end

      # If LDAP is not enabled, then it returns the reason for it (e.g. the
      # Portus user is trying to authenticate and it never goes to
      # LDAP). Otherwise it returns an empty string.
      def reason_message
        return "" if @enabled

        @reason.presence || "LDAP is not enabled"
      end

      protected

      # Sets the @reason instance variable and returns false if there's
      # something about the current accounts telling us to not go through LDAP
      # (e.g. portus user). Otherwise it returns true.
      def check_account(account)
        if account == "portus"
          @reason = "Portus user does not go through LDAP"
          false
        elsif @username.present?
          user = User.find_by(username: @username)

          if user&.bot
            @reason = "Bot user is not expected to be present on LDAP"
            false
          else
            # This case only makes sense if the LDAP authenticatable has been
            # added even when it shouldn't (i.e. the code on
            # config/initializers/devise.rb failed for whatever reason).
            if user&.encrypted_password == ""
              @reason = "This user can only authenticate if LDAP is enabled"
              @soft   = false
            end
            true
          end
        else
          true
        end
      end
    end
  end
end
