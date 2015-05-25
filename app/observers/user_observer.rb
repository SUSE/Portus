class UserObserver < ActiveRecord::Observer

  def after_create(user)
    user.create_personal_namespace!
  end

end
