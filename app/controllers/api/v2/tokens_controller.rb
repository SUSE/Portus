class Api::V2::TokensController < Api::BaseController

  before_filter :authenticate_user!

  def show
    if params[:scope]
      logger.info "SCOPE is #{params[:scope]}"
      auth_scope, scopes = scope_handler(params[:scope])
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
