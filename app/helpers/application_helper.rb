module ApplicationHelper
  def can_manage_namespace?(namespace)
    current_user.admin? || namespace.team.owners.exists?(current_user.id)
  end

  def namespace_clean_name(namespace)
    if namespace.global?
      namespace.registry.hostname
    else
      namespace.name
    end
  end
end
