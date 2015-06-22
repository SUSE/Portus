class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authenticate_user!
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  respond_to :html

  def after_sign_in_path_for(_resource)
    root_url
  end

  def after_sign_out_path_for(_resource)
    new_user_session_url
  end

  protected

  def deny_access
    render text: 'Access Denied', status: :unauthorized
  end
end
