class Api::BaseController < ActionController::Base
  class ScopeNotHandled < StandardError; end
  class RegistryNotHandled < StandardError; end
  class WrongPortusOTP < StandardError; end

  include Pundit

  respond_to :json

  rescue_from Namespace::AuthScope::ResourceIsNotFound, with: :deny_access
  rescue_from Pundit::NotAuthorizedError, with: :deny_access
  rescue_from ScopeNotHandled, with: :deny_access
  rescue_from RegistryNotHandled, with: :deny_access
  rescue_from WrongPortusOTP, with: :deny_access

  protected

  def deny_access
    head :unauthorized
  end

  def scope_handler(registry, scope_string)
    type = scope_string.split(":", 3)[0]

    case type
    when "repository"
      auth_scope = Namespace::AuthScope.new(registry, scope_string)
    else
      logger.error "Scope not handled: #{type}"
      raise ScopeNotHandled
    end

    scopes = scope_string.split(":", 3)[2].split(",")

    [auth_scope, scopes]
  end
end
