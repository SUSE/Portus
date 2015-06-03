class Auth::RegistrationsController < Devise::RegistrationsController

  layout 'authentication', except: :edit

  before_filter :check_admin, only: [ :new, :create ]
  before_filter :configure_sign_up_params, only: [ :create ]

  def update
    success =
    if password_update?
      current_user.update_with_password(params.require(:user).permit(
        :password, :password_confirmation, :current_password
      ))
    else
      current_user.update_without_password(params.require(:user).permit(:email))
    end

    if success
      redirect_to edit_user_registration_url,
        notice: 'Profile updated successfully!'
    else
      redirect_to edit_user_registration_url,
        alert: resource.errors.full_messages[0]
    end
  end

  def check_admin
    @admin = User.exists?(admin: true)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :email
    unless User.exists?(admin: true)
      devise_parameter_sanitizer.for(:sign_up) << :admin
    end
  end

  protected

  # Returns true if the contents of the `params` hash contains the needed keys
  # to update the password of the user.
  def password_update?
    user = params[:user]
    !user[:current_password].blank? || !user[:password].blank? ||
      !user[:password_confirmation].blank?
  end

end
