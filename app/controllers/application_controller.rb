# frozen_string_literal: true

require "portus/auth_from_token"

class ApplicationController < ActionController::Base
  include ::Portus::Checks
  before_action :check_requirements

  include ::Portus::AuthFromToken
  before_action :authenticate_user_from_authentication_token!

  before_action :authenticate_user!
  before_action :force_update_profile!
  before_action :force_registry_config!

  include Headers

  protect_from_forgery with: :exception, prepend: true

  add_flash_types :float

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  respond_to :html, :json

  # Two things can happen when signing in.
  #   1. The current user has no email: this happens on LDAP registration. In
  #      this case, the user will be asked to submit an email.
  #   2. If the sign-in action was triggered trying to access a specific page
  #      go back to it
  #   3. Or go to the root url.
  def after_sign_in_path_for(resource)
    current_user.email? ? super : edit_user_registration_path
  end

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end

  protected

  # Authenticate the user:token as provided in the "PORTUS-AUTH" header.
  def authenticate_user_from_authentication_token!
    auth = request.headers["PORTUS-AUTH"].presence
    return if auth.nil?

    username, password = auth.split(":")
    user = User.find_by(username: username)
    sign_in(user, store: false) if user&.application_token_valid?(password)
  end

  # Redirect users to their profile page if they haven't set up their email
  # account (this happens when signing up through LDAP suppor).
  def force_update_profile!
    return unless current_user && !current_user.email?
    return if protected_controllers?

    redirect_to edit_user_registration_path
  end

  # Redirect admin users to the registries#new page if no registry has been
  # setup yet.
  def force_registry_config!
    return unless current_user&.admin?
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
      format.all { render body: nil, status: @status }
    end
  end
end
