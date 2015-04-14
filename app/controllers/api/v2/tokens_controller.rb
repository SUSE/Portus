class Api::V2::TokensController < Api::BaseController

  def show
    token_request_params
    token_request_params.permitted?
    @token = {}
    respond_with(@token)
  end

  protected

  def token_request_params
    params.permit(:account, :service, :scope)
  end

end
