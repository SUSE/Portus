class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    registry = Registry.find_by(hostname: params['service'])
    raise RegistryNotHandled if registry.nil?

    if params[:scope]
      auth_scope, scopes = scope_handler(registry, params[:scope])
      scopes.each do |scope|
        authorize auth_scope.resource, "#{scope}?".to_sym
      end
    end

    @token = JwtToken.new(
      account: params[:account],
      service: params[:service],
      scope: auth_scope
    )

    logger.tagged('jwt_token', 'claim') { logger.debug @token.claim }
    respond_with(@token)
  end

end
