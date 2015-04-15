class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    @token = JwtToken.new(
        account: params[:account],
        service: params[:service],
        scope: params[:scope]
    )
    respond_with(@token)
  end

end
