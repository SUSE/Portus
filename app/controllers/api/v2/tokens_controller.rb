class Api::V2::TokensController < Api::BaseController

  def show
    @token = JwtToken.new(
      account: params[:account],
      service: params[:service],
      scope: params[:scope]
    )
    respond_with(@token)
  end

end
