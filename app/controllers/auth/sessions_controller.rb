class Auth::SessionsController < Devise::SessionsController
  layout "authentication"

  # Re-implementing. The logic is: if there is already a user that can log in
  # or LDAP support is enabled, work as usual. Otherwise, redirect always to
  # the signup page.
  def new
    signup_allowed = !Portus::LDAP.enabled? && APP_CONFIG.enabled?("signup")

    if User.not_portus.any? || !signup_allowed
      @errors_occurred = flash[:alert] && !flash[:alert].empty?
      super
    else
      # For some reason if we get here from the root path, we'll get a flashy
      # alert message.
      flash[:alert] = nil
      redirect_to new_user_registration_url
    end
  end

  # Re-implementing both the create and the destroy methods in order to avoid
  # showing the redundant "Signed in/out" flashy messages.

  def create
    super
    flash[:notice] = nil
  end

  def destroy
    super
    flash[:notice] = nil
  end
end
