class ApplicationController < ActionController::Base
  before_action :check_requirements
  helper_method :fixes
  before_action :authenticate_user!
  before_action :force_update_profile!
  before_action :force_registry_config!
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  respond_to :html, :json

  # Two things can happen when signing in.
  #   1. The current user has no email: this happens on LDAP registration. In
  #      this case, the user will be asked to submit an email.
  #   2. Everything is fine, go to the root url.
  def after_sign_in_path_for(_resource)
    current_user.email? ? root_url : edit_user_registration_url
  end

  def after_sign_out_path_for(_resource)
    new_user_session_url
  end

  def fixes
    secrets = Rails.application.secrets
    check_ssl = Rails.env.production? && \
      !request.ssl? && \
      APP_CONFIG.enabled?("check_ssl_usage")

    {}.tap do |fix|
      fix[:ssl]                                = check_ssl
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
    redirect_to "/500?fixes=true"
  end

  # Redirect users to their profile page if they haven't set up their email
  # account (this happens when signing up through LDAP suppor).
  def force_update_profile!
    return unless current_user && !current_user.email?
    return if protected_controllers?

    redirect_to edit_user_registration_url
  end

  # Redirect admin users to the registries#new page if no registry has been
  # setup yet.
  def force_registry_config!
    return unless current_user && current_user.admin?
    return if Registry.any?
    return if protected_controllers?("admin/registries")

    redirect_to new_admin_registry_path
  end

  # Returns true if the current controller is a "protected" controller. A
  # protected controller is either the auth/registrations, auth/sessions or
  # either of the supplied controllers.
  #
  # Use this method to avoid infinite redirect loops in before_action filters.
  def protected_controllers?(*controllers)
    controller = params[:controller]
    return true if controller == "auth/registrations" || controller == "auth/sessions"
    controllers.each { |c| return true if c == controller }
    false
  end

  # Render the 401 page.
  def deny_access
    @status = 401
    respond_to do |format|
      format.html { render template: "errors/401", status: @status, layout: "errors" }
      format.all { render nothing: true, status: @status }
    end
  end
end
