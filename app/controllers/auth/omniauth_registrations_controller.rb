# frozen_string_literal: true

class Auth::OmniauthRegistrationsController < ApplicationController
  layout "authentication"
  skip_before_action :authenticate_user!

  # GET /users/oauth
  def new
    if session["omniauth.auth"]
      @user = User.new(
        username:     session["omniauth.auth"]["info"]["username"],
        display_name: session["omniauth.auth"]["info"]["name"]
      )
      @user.suggest_username session["omniauth.auth"]["info"]
    else
      redirect_to new_user_session_url
    end
  end

  # POST /users/oauth
  def create
    user = User.create_from_oauth user_params, session["omniauth.auth"]

    if user.persisted?
      session.delete "omniauth.auth"
      flash[:notice] = "Successfully registered as '#{user.username}'!"
      sign_in_and_redirect user, event: :authenticate
    else
      redirect_to users_oauth_url, alert: user.errors.full_messages.join("\n")
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :display_name)
  end
end
