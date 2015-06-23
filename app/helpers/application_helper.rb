module ApplicationHelper
  def can_manage_namespace?(namespace)
    current_user.admin? || namespace.team.owners.exists?(current_user.id)
  end
end
