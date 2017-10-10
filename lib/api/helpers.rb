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
      return if request.request_method == "OPTIONS"

      current_user

      error!("Authentication fails.", 401) unless @user
      raise Pundit::NotAuthorizedError if force_admin && !@user.admin
    end

    # Authenticate from the warden session if possible.
    def authenticate_from_warden
      warden = env["warden"]
      return unless warden

      env["warden"].authenticate(scope: "user")
    end

    # Helper method to make Pundit happy. It will set a `@user` instance
    # variable with either the current user as stored by Devise or the one taken
    # from the authentication token.
    def current_user
      @user = authenticate_from_warden
      if @user
        @type = :internal
      else
        @type = :official
        @user = authenticate_user_from_authentication_token!
      end
      @user
    end

    # Returns the current type of API presentation. The two options available
    # are: :official and :internal. The :internal type is the same as the
    # official one, but with some extensions that come in handy for the client
    # side.
    def current_type
      @type
    end

    # Behaves like strong parameters. It will only permit the parameters
    # declared on the endpoint params
    def permitted_params
      @permitted_params ||= declared(params,
                                     include_missing:           false,
                                     include_parent_namespaces: false)
    end

    # Helpers for namespaces
    module Namespaces
      # Returns an aggregate of the accessible namespaces for the current user.
      def accessible_namespaces
        special = Namespace.special_for(current_user).order(created_at: :asc)
        normal  = policy_scope(Namespace).order(created_at: :asc)
        special + normal
      end
    end

    # Helpers of teams
    module Teams
      # Prettify the role of the given user within the given team. You can pass
      # the value to be returned if this user does not belong to the team with
      # the `empty` argument.
      def role_within_team(user, team, empty = nil)
        team_user = team.team_users.find_by(user_id: user.id)
        if team_user
          team_user.role.titleize
        else
          empty
        end
      end
    end
  end
end
