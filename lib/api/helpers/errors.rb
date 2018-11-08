# frozen_string_literal: true

require "portus/auth_from_token"

module API
  module Helpers
    # Errors implements helper methods for API error responses.
    module Errors
      # Sends a `400 Bad Request` error with a possible message as the response
      # body.
      def bad_request!(msg = "Bad Request")
        error!(msg, 400)
      end

      # Sends a `401 Unauthorized` error with a possible message as the response
      # body.
      def unauthorized!(msg = "Unauthorized")
        error!(msg, 401)
      end

      # Sends a `403 Forbidden` error with a possible message as the response
      # body.
      def forbidden!(msg = "Forbidden")
        error!(msg, 403)
      end

      # Sends a `404 Not found` error with a possible message as the response
      # body.
      def not_found!(msg = "Not found")
        error!(msg, 404)
      end

      # Sends a `405 Method Not Allowed` error with a possible message as the
      # response body.
      def method_not_allowed!(msg = "Method Not Allowed")
        error!(msg, 405)
      end

      # Sends a `422 Unprocessable Entity` error with a possible message as the
      # response body.
      def unprocessable_entity!(msg = "Unprocessable Entity")
        error!(msg, 422)
      end

      # Sends a `405 Internal Server Error` error with a possible message as the
      # response body.
      def internal_server_error!(msg = "Internal Server Error")
        error!(msg, 500)
      end
    end
  end
end
