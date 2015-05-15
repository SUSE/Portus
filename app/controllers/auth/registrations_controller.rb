class Auth::RegistrationsController < Devise::RegistrationsController

  layout 'authentication'

  before_filter :check_admin, only: [ :new, :create ]
  before_filter :configure_sign_up_params, only: [ :create ]

  def check_admin
    @admin = User.exists?(admin: true)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :email
    unless User.exists?(admin: true)
      devise_parameter_sanitizer.for(:sign_up) << :admin
    end
  end

end
