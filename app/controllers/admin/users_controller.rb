class Admin::UsersController < Admin::BaseController
  respond_to :html, :js

  def index
    @users = User.all
  end

  # PATCH/PUT /admin/user/1/toggle_admin
  def toggle_admin
    user = User.find(params[:id])
    user.update_attributes(admin: !(user.admin?))
    if user == current_user
      # This user is no longer an admin
      render js: "window.location = '/'"
    else
      render template: 'admin/users/toggle_admin', locals: { user: user }
    end
  end

end
