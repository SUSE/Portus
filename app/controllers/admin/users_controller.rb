# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :another_user_access, only: %i[edit]
  before_action :check_ldap_user!, only: %i[create]

  def index
    @admin_count = User.admins.count
    @users = User.not_portus.order(:username)
    @users_serialized = API::Entities::Users.represent(
      @users,
      current_user: current_user,
      type:         :internal
    ).to_json
  end

  def create
    @user = User.create(user_create_params)

    respond_to do |format|
      if @user.persisted?
        @user_serialized = API::Entities::Users.represent(
          @user,
          current_user: current_user,
          type:         :internal
        )
        @hash = {
          user: @user_serialized
        }

        _, plain_token = create_application_token!(@user) if @user.bot
        @hash[:plain_token] = plain_token if plain_token.present?

        format.json { render json: @hash }
      else
        format.json { render json: @user.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/user/1/edit
  def edit
    @user_serialized = API::Entities::Users.represent(
      @user,
      current_user: current_user,
      type:         :internal
    ).to_json
    @app_tokens_serialized = API::Entities::ApplicationTokens.represent(
      @user.application_tokens,
      current_user: current_user,
      type:         :internal
    ).to_json
  end

  # PATCH/PUT /admin/user/1/toggle_admin
  def toggle_admin
    user = User.find(params[:id])

    if user == current_user
      render body: nil, status: :forbidden
    else
      user.toggle_admin!
      render body: nil
    end
  end

  private

  def user_create_params
    permitted = %i[username email password password_confirmation bot]
    params.require(:user).permit(permitted)
  end

  # Sets the @user instance variable if the current user is different from the
  # one specified in params[:id]. Moreover, if the current user is the same as
  # the targeted one, then a 403 response is rendered.
  def another_user_access
    @user = User.find(params[:id])
    return if !@user.nil? && @user != current_user

    @user = nil
    render body: nil, status: :forbidden
  end

  # It creates an application token associated to the user that is being
  # passed through parameter
  def create_application_token!(user)
    ApplicationToken.create_token(
      current_user: current_user,
      user_id:      user.id,
      params:       { application: "default" }
    )
  end

  # If LDAP is enabled, it checks that the user to be created does not collide
  # with the username of an LDAP existing user.
  def check_ldap_user!
    msg = ::Portus::LDAP::Search.new.with_error_message(user_create_params[:username])
    return if msg.nil?

    Rails.logger.tagged(:ldap) { Rails.logger.debug msg }
    respond_to do |format|
      format.json { render json: { ldap: [msg] }, status: :unprocessable_entity }
    end
  end
end
