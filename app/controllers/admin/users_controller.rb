class Admin::UsersController < Admin::BaseController
  respond_to :html, :js

  def index
    @users = User.not_portus.page(params[:page])
    @admin_count = User.admins.count
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
end
