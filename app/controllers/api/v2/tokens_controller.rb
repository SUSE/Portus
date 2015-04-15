class Api::V2::TokensController < Api::BaseController

  def show
    authenticate_or_request_with_http_basic do |username,password|
      resource = User.find_by_username(username)
      if resource && resource.valid_password?(password)
        sign_in :user, resource
        @token = JwtToken.new(
          account: params[:account],
          service: params[:service],
          scope: params[:scope]
        )
        respond_with(@token)
      else
        head 401
      end
    end

  end

end
