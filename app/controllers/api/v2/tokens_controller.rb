class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    if params[:scope]
      registry_scope = Namespace::AuthScope.new(params[:scope])
      authorize registry_scope.resource, :pull?
      authorize registry_scope.resource, :push?
    end

    @token = JwtToken.new(
      account: params[:account],
      service: params[:service],
      scope: registry_scope
    )

    logger.tagged('jwt_token', 'claim') { logger.debug @token.claim }
    respond_with(@token)
  end

end
