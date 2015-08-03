class Api::V2::TokensController < Api::BaseController
  before_action :authenticate

  def authenticate
    if params["account"] == "portus"
      totp = ROTP::TOTP.new(Rails.application.config.otp_secret)

      authenticate_with_http_basic do |u, p|
        raise WrongPortusOTP if u != "portus" || p != totp.now
      end
    else
      authenticate_user!
    end
  end

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

  def authorize_scopes(registry)
    # The 'portus' user can do anything
    return unless params[:scope] && params["account"] != "portus"

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
end
