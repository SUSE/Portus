class Auth::SessionsController < Devise::SessionsController

  layout 'authentication'

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
