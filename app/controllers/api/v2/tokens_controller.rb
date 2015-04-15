class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    @token = JwtToken.new(
        account: params[:account],
        service: params[:service],
        scope: params[:scope]
    )
    logger.tagged('jwt_token', 'claim') { logger.debug @token.claim }
    respond_with(@token)
  end

end
