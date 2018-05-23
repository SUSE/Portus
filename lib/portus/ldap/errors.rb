# frozen_string_literal: true

module Portus
  module LDAP
    # Error to be raised when there's something wrong around the library (not
    # the LDAP server itself, that should be already handled by Net::LDAP).
    class Error < StandardError; end

    # Errors contains some utility methods for error handling.
    module Errors
      # logged_error_message! is a shorthand for calling `error_message` and
      # `logged_failure!` in combination.
      def logged_error_message!(obj, name = "")
        msg = error_message(obj, name)
        logged_failure!(msg)
      end

      # error_message returns a string containing a more descriptive error
      # message for the given object. You may also want to provide the name of
      # the user which tried to authenticate.
      def error_message(obj, name = "")
        if name.present? && obj.get_operation_result.code.zero?
          "Could not find user '#{name}'"
        else
          "#{obj.get_operation_result.message} (code #{obj.get_operation_result.code})"
        end
      end

      # logged_failure! logs the given message and calls `fail!` with this same
      # message.
      def logged_failure!(message)
        Rails.logger.tagged(:ldap) { Rails.logger.error("#{message}.") }
        fail!(message)
      end
    end
  end
end
