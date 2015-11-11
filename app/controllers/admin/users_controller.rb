class Admin::UsersController < Admin::BaseController
  respond_to :html, :js

  def index
    @users = User.not_portus.page(params[:page])
    @admin_count = User.admins.count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_create_params)

    if @user.persisted?
      flash[:notice] = "User created successfully!"
      redirect_to admin_users_path
    else
      flash[:alert] = @user.errors.full_messages
      render "new"
    end
  end

  # PATCH/PUT /admin/user/1/toggle_admin
  def toggle_admin
    user = User.find(params[:id])

    if user == current_user
      render nothing: true, status: 403
    else
      user.toggle_admin!
      render template: "admin/users/toggle_admin", locals: { user: user }
    end
  end

  private

  def user_create_params
    permitted = [:username, :email, :password, :password_confirmation]
    params.require(:user).permit(permitted)
  end
end
