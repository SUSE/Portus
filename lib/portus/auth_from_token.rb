# frozen_string_literal: true

module Portus
  # AuthFromToken includes methods for authenticating users through an
  # application token. This may apply to either controllers or the Rest API, and
  # hence is left as a separate library.
  module AuthFromToken
    # Authenticate the given user by token. The token is passed by the
    # Portus-Auth header parameters, the value of which is formatted as follows:
    # "username:token". The given token should be a valid application token for
    # the given user.
    def authenticate_user_from_authentication_token!
      auth = request.headers["Portus-Auth"].presence
      return if auth.nil?

      username, password = auth.split(":")
      user = User.find_by(username: username)

      # Sign in when it included in controller.
      return unless user&.application_token_valid?(password)

      sign_in(user, store: false) if respond_to? :sign_in
      user
    end
  end
end
