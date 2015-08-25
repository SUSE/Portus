class ApplicationController < ActionController::Base
  before_action :check_requirements
  before_action :authenticate_user!
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

  # Check whether certain requirements are met, like ssl configuration
  # for production or having setup secrets.
  # If they are not met, render a page with status 500
  def check_requirements
    # select any model to check database connection
    # if database is not configured it will raise an exception
    User.first
    fix_secrets = Rails.application.secrets.secret_key_base == "CHANGE_ME"
    fix_ssl = Rails.env.production? && !request.ssl?
    return unless fix_secrets || fix_ssl
    redirect_to "/errors/500?fix_ssl=#{fix_ssl}&fix_secrets=#{fix_secrets}", status: 500
  end

  def fixes
    fix_secrets = true if Rails.application.secrets.secret_key_base == "CHANGE_ME"
    fix_ssl     = true if Rails.env.production? && !request.ssl?
    [fix_secrets, fix_ssl]
  end

  def deny_access
    render text: "Access Denied", status: :unauthorized
  end
end
