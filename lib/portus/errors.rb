# frozen_string_literal: true

module Portus
  # Errors contain registry-specific errors that have no real implementation.
  module Errors
    # Networking errors given usually on this application. This is useful to
    # catch a set of common networking issues on a single rescue statement.
    NET = [SocketError, OpenSSL::SSL::SSLError, Net::HTTPBadResponse,
           Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, EOFError,
           Errno::ETIMEDOUT, Net::OpenTimeout, Net::ReadTimeout].freeze

    # Returns a string with a message representing the given exception.
    def self.message_from_exception(klass)
      case klass
      when SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        "connection refused"
      when Errno::ECONNRESET
        "connection reset"
      when OpenSSL::SSL::SSLError, Net::HTTPBadResponse
        "could not stablish connection: SSL error"
      when Errno::ETIMEDOUT, Net::OpenTimeout
        "connection timed out"
      end
    end

    # As specified in the token specification of distribution, the client will
    # get a 401 on the first attempt of logging in, but in there should be the
    # "WWW-Authenticate" header. This exception will be raised when there's no
    # authentication token bearer.
    class NoBearerRealmException < RuntimeError; end

    # Raised when the authorization token could not be fetched.
    class AuthorizationError < RuntimeError; end

    # Used when a resource was not found for the given endpoint.
    class NotFoundError < RuntimeError; end

    # Raised if this client does not have the credentials to perform an API call.
    class CredentialsMissingError < RuntimeError; end

    # Used when a parameter of a request is invalid semantically speaking
    # (e.g. an integer was passed instead of a string).
    class UnprocessableEntity < RuntimeError; end
  end
end
