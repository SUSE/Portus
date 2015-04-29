class UserObserver < ActiveRecord::Observer

  def after_create(user)
    user.create_personal_team!
  end

end
