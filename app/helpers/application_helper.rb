module ApplicationHelper

  def is_namespace_owner?(namespace)
    namespace.team.owners.exists?(current_user.id)
  end

end
