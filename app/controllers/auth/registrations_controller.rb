class Auth::RegistrationsController < Devise::RegistrationsController

  layout 'authentication'

  before_filter :configure_sign_up_params, only: [ :create ]

  def new
    @admin = User.exists?(admin: true)
    super
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :email
    unless User.exists?(admin: true)
      devise_parameter_sanitizer.for(:sign_up) << :admin
    end
  end

end
