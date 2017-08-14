# Common method for token authentication.
module AuthFromToken
  extend ActiveSupport::Concern

  # Authentication user by token. Token pass by Portus-Auth header param.
  # The param value is string whoch contains username and token splitted by colon.
  # For success authentication the token should belong to the user.
  def authenticate_user_from_authentication_token!
    auth = request.headers["Portus-Auth"].presence
    return if auth.nil?
    username, password = auth.split(":")
    user = User.find_by(username: username)

    if user && user.application_token_valid?(password)
      # Sign in when it included in controller.
      sign_in(user, store: false) if respond_to? :sign_in
      user
    end
  end
end
