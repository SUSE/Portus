class Api::BaseController < ActionController::Base

  include Pundit

  respond_to :json

  rescue_from Registry::AuthScope::ResourceIsNotDefined, with: :deny_access
  rescue_from Registry::AuthScope::ResourceIsNotFound, with: :deny_access

  protected

  def deny_access
    head :unauthorized
  end

end
