# TokensController is used to deliver the token that the docker client should
# use in order to perform operation into the registry. This is the last step in
# the authentication process for Portus' point of view.
class Api::V2::TokensController < Api::BaseController
  before_action :authenticate_user!

  # Returns the token that the docker client should use in order to perform
  # operation into the private registry.
  def show
    registry = Registry.find_by(hostname: params["service"])
    raise RegistryNotHandled if registry.nil?

    auth_scope = authorize_scopes(registry)

    @token = JwtToken.new(
      account: params[:account],
      service: params[:service],
      scope:   auth_scope
    )

    logger.tagged("jwt_token", "claim") { logger.debug @token.claim }
    respond_with(@token)
  end

  private

  # If there was a scope specified in the request parameters, try to authorize
  # the given scopes. That is, it "filters" the scopes that can be requested
  # depending of the issuer of the request and its permissions.
  def authorize_scopes(registry)
    return unless params[:scope]

    auth_scope, scopes = scope_handler(registry, params[:scope])
    scopes.each do |scope|
      begin
        authorize auth_scope.resource, "#{scope}?".to_sym
      rescue NoMethodError
        logger.warn "Cannot handle scope #{scope}"
        raise ScopeNotHandled, "Cannot handle scope #{scope}"
      end
    end

    auth_scope
  end

  # From the given scope string, try to fetch a scope handler class for it.
  # Scope handlers are defined in "app/models/*/auth_scope.rb" files.
  def scope_handler(registry, scope_string)
    type = scope_string.split(":", 3)[0]

    case type
    when "repository"
      auth_scope = Namespace::AuthScope.new(registry, scope_string)
    else
      logger.error "Scope not handled: #{type}"
      raise ScopeNotHandled
    end

    scopes = scope_string.split(":", 3)[2].split(",")

    [auth_scope, scopes]
  end
end
