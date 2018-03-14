
# frozen_string_literal: true

require "portus/auth_from_token"

module API
  module Helpers
    # Errors implements helper methods for API error responses.
    module Errors
      def api_error!(code:, messages:)
        obj = messages.is_a?(String) ? [messages] : messages
        error!(obj, code)
      end

      # Sends a `400 Bad Request` error with a possible message as the response
      # body.
      def bad_request!(msg = "Bad Request")
        api_error!(code: 400, messages: msg)
      end

      # Sends a `401 Unauthorized` error with a possible message as the response
      # body.
      def unauthorized!(msg = "Unauthorized")
        api_error!(code: 401, messages: msg)
      end

      # Sends a `403 Forbidden` error with a possible message as the response
      # body.
      def forbidden!(msg = "Forbidden")
        api_error!(code: 403, messages: msg)
      end

      # Sends a `404 Not found` error with a possible message as the response
      # body.
      def not_found!(msg = "Not found")
        api_error!(code: 404, messages: msg)
      end

      # Sends a `405 Method Not Allowed` error with a possible message as the
      # response body.
      def method_not_allowed!(msg = "Method Not Allowed")
        api_error!(code: 405, messages: msg)
      end

      # Sends a `422 Unprocessable Entity` error with a possible message as the
      # response body.
      def unprocessable_entity!(msg = "Unprocessable Entity")
        api_error!(code: 422, messages: msg)
      end

      # Sends a `405 Internal Server Error` error with a possible message as the
      # response body.
      def internal_server_error!(msg = "Internal Server Error")
        api_error!(code: 500, messages: msg)
      end
    end
  end
end
