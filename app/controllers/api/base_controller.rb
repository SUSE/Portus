class Api::BaseController < ActionController::Base
  class ScopeNotHandled < StandardError; end

  include Pundit

  respond_to :json

  rescue_from Namespace::AuthScope::ResourceIsNotFound, with: :deny_access
  rescue_from Pundit::NotAuthorizedError, with: :deny_access
  rescue_from ScopeNotHandled, with: :deny_access

  protected

  def deny_access
    head :unauthorized
  end

  def scope_handler(scope_string)
    type = scope_string.split(':')[0]
    case type
    when 'repository'
      Namespace::AuthScope.new(scope_string)
    else
      logger.error "Scope not handled: #{type}"
      raise ScopeNotHandled
    end
  end

end
