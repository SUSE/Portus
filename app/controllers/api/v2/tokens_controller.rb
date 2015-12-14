# TokensController is used to deliver the token that the docker client should
# use in order to perform operation into the registry. This is the last step in
# the authentication process for Portus' point of view.
class Api::V2::TokensController < Api::BaseController
  before_action :attempt_authentication_against_application_tokens

  # Try to perform authentication using the application tokens. The password
  # provided via HTTP basic auth is going to be checked against the application
  # tokens a user might have created.
  # If the user has a valid application token then the other forms of
  # authentication (Portus' database, LDAP) are going to be skipped.
  def attempt_authentication_against_application_tokens
    user = authenticate_with_http_basic do |username, password|
      user = User.find_by(username: username)
      user if user && user.application_token_valid?(password)
    end
    sign_in(user, store: true) if user
  end

  # Returns the token that the docker client should use in order to perform
  # operation into the private registry.
  def show
    registry = Registry.find_by(hostname: params[:service])
    raise RegistryNotHandled, "Cannot find registry #{params[:service]}" if registry.nil?

    auth_scope = authorize_scopes(registry)
    authenticate_user! if auth_scope.nil?

    token = Portus::JwtToken.new(params[:account], params[:service], auth_scope)
    logger.tagged("jwt_token", "claim") { logger.debug token.claim }
    render json: token.encoded_hash
  end

  private

  # If there was a scope specified in the request parameters, try to authorize
  # the given scopes. That is, it "filters" the scopes that can be requested
  # depending of the issuer of the request and its permissions.
  #
  # If no scope was specified, this is a login request and it just returns nil.
  def authorize_scopes(registry)
    return unless params[:scope]

    # First try to fetch the requested scopes and the handler. If no scopes
    # were successfully given, respond with a 401.
    auth_scope, scopes = scope_handler(registry, params[:scope])
    raise Pundit::NotAuthorizedError, "No scopes to handle" if scopes.empty?

    scopes.each do |scope|
      # It will try to check if the current user is authorized to access the
      # scope given in this iteration. If everything is fine, then nothing will
      # happen, otherwise there are two possible exceptions that can be raised:
      #
      #   - NoMethodError: the targeted resource does not handle the scope that
      #     is being checked. It will raise a ScopeNotHandled.
      #   - Pundit::NotAuthorizedError: the targeted resource unauthorized the
      #     given user for the scope that is being checked. In this case this
      #     scope gets removed from `auth_scope.actions`.
      begin
        authorize auth_scope.resource, "#{scope}?".to_sym
      rescue NoMethodError, Pundit::NotAuthorizedError
        logger.debug "scope #{scope} not handled/authorized, removing from actions"
        auth_scope.actions.delete_if { |a| a == scope }
      end
    end

    # If auth_scope.actions is empty, it means that the previous loop
    # unauthorized all the requested scopes for the current user. Therefore
    # respond with a 401. Otherwise, return the resulting auth_scope.
    msg = "None of the given scopes were authorized for the current user"
    raise Pundit::NotAuthorizedError, msg if auth_scope.actions.empty?
    auth_scope
  end

  # From the given scope string, try to fetch a scope handler class for it.
  # Scope handlers are defined in "app/models/*/auth_scope.rb" files.
  def scope_handler(registry, scope_string)
    str = scope_string.split(":", 3)
    raise ScopeNotHandled, "Wrong format for scope string" if str.length != 3

    case str[0]
    when "repository"
      auth_scope = Namespace::AuthScope.new(registry, scope_string)
    when "registry"
      auth_scope = Registry::AuthScope.new(registry, scope_string)
    else
      raise ScopeNotHandled, "Scope not handled: #{str[0]}"
    end

    [auth_scope, auth_scope.scopes.dup]
  end
end
