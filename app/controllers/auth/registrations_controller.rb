class Auth::RegistrationsController < Devise::RegistrationsController

  layout 'authentication'

  before_filter :configure_sign_up_params, only: [ :create ]

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :email
  end

end
