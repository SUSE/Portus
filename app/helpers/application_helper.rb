module ApplicationHelper
  def can_manage_namespace?(namespace)
    current_user.admin? || namespace.team.owners.exists?(current_user.id)
  end

  # Render the user profile picture depending on the gravatar configuration.
  def user_image_tag(email, size = 1)
    if APP_CONFIG.enabled?("gravatar")
      gravatar_image_tag(email)
    else
      render html: "<i class=\"fa fa-user fa-#{size}x\"></i>".html_safe
    end
  end
end
