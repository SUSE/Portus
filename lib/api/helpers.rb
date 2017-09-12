require "portus/auth_from_token"

module API
  module Helpers
    include ::Portus::AuthFromToken

    # On success it will fill the @user instance variable with the currently
    # authenticated user for the API. Otherwise it will raise:
    #
    #   - A 401 error if the given user could not be found or it was not given
    #     at all.
    #   - A Pundit::NotAuthorizedError if `force_admin` was set to true and the
    #     currently authenticated user is not an admin.
    #
    # The `force_admin` option should be used when the endpoints affected by
    # this should only apply to Portus administrators (e.g. user management).
    def authorization!(force_admin: true)
      return if current_user
      return if request.request_method == "OPTIONS"
      @user = authenticate_user_from_authentication_token!
      error!("Authentication fails.", 401) unless @user
      raise Pundit::NotAuthorizedError if force_admin && !@user.admin
    end

    # Helper method to make Pundit happy. It will return the `@user` instance
    # variable set by the `authorization!` method or the current user as stored
    # by Devise.
    def current_user
      return @user if @user

      warden = env["warden"]
      return unless warden

      @user = env["warden"].authenticate(scope: "user")
      @user
    end

    # TODO: really ?
    def user_session
      current_user && warden.session(:user)
    end
  end
end
