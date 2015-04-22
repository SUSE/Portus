class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    if params[:scope]
      scope = scope_handler(params[:scope])
      authorize scope.resource, :pull?
      authorize scope.resource, :push?
    end

    @token = JwtToken.new(
      account: params[:account],
      service: params[:service],
      scope: scope
    )

    logger.tagged('jwt_token', 'claim') { logger.debug @token.claim }
    respond_with(@token)
  end

end
