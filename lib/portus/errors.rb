# frozen_string_literal: true

module Portus
  # Errors contain registry-specific errors that have no real implementation.
  module Errors
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
  end
end
