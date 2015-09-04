class ApplicationController < ActionController::Base
  before_action :check_requirements
  helper_method :fixes
  before_action :authenticate_user!
  before_action :force_update_profile!
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  respond_to :html

  # Two things can happen when signing in.
  #   1. The current user has no email: this happens on LDAP registration. In
  #      this case, the user will be asked to submit an email.
  #   2. Everything is fine, go to the root url.
  def after_sign_in_path_for(_resource)
    current_user.email.empty? ? edit_user_registration_url : root_url
  end

  def after_sign_out_path_for(_resource)
    new_user_session_url
  end

  def fixes
    secrets = Rails.application.secrets
    {}.tap do |fix|
      fix[:ssl]                                = Rails.env.production? && !request.ssl?
      fix[:secret_key_base]                    = secrets.secret_key_base == "CHANGE_ME"
      fix[:secret_machine_fqdn]                = secrets.machine_fqdn.nil?
      fix[:secret_encryption_private_key_path] = secrets.encryption_private_key_path.nil?
      fix[:secret_portus_password]             = secrets.portus_password.nil?
      fix
    end
  end

  protected

  # Check whether certain requirements are met, like ssl configuration
  # for production or having setup secrets.
  # If they are not met, render a page with status 500
  def check_requirements
    return unless fixes.value?(true)
    redirect_to "/errors/500"
  end

  # Redirect users to their profile page if they haven't set up their email
  # account (this happens when signing up through LDAP suppor).
  def force_update_profile!
    return unless current_user && current_user.email.empty?

    controller = params[:controller]
    return if controller == "auth/registrations" || controller == "auth/sessions"
    redirect_to edit_user_registration_url
  end

  def deny_access
    render text: "Access Denied", status: :unauthorized
  end
end
