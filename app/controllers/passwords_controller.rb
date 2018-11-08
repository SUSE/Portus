# frozen_string_literal: true

# PasswordsController is a Devise controller that takes care of the "password
# forgotten" mechanism.
class PasswordsController < Devise::PasswordsController
  layout "authentication"

  before_action :check_portus, only: %i[create]

  include CheckLDAP

  # Re-implemented from Devise to respond with a proper message on error.
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      redirect_to new_user_password_path, alert: resource.errors.full_messages, float: true
    end
  rescue *::Portus::Errors::NET, ::Net::SMTPAuthenticationError => e
    from = ::Portus::Errors.message_from_exception(e)
    msg  = "#{e}: #{from}"
    Rails.logger.tagged("Mailer") { Rails.logger.info msg }
    redirect_to new_user_password_path,
                alert: "Something went wrong. Check the configuration of Portus",
                float: true
  end

  # Re-implemented from Devise to respond with a proper message on error.
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      update_success
    else
      token = params[:user][:reset_password_token]
      redirect_to "/users/password/edit?reset_password_token=#{token}",
                  alert: resource.errors.full_messages, float: true
    end
  end

  protected

  def update_success
    resource.unlock_access! if unlockable?(resource)

    flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    set_flash_message(:notice, flash_message) if is_flashing_format?
    sign_in(resource_name, resource)

    respond_with resource, location: after_resetting_password_path_for(resource), float: true
  end

  # Prevents redirect loops
  def after_resetting_password_path_for(resource)
    signed_in_root_path(resource)
  end

  # Prevents the portus user from resetting the password.
  def check_portus
    user = User.find_by(email: resource_params["email"])
    return if user.nil? || !user.portus?

    redirect_to new_user_session_path,
                alert: "Action not allowed on this user",
                float: true
  end
end
