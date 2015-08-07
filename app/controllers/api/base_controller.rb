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
end
