module TeamsHelper
  include ::API::Helpers::Teams

  def can_manage_team?(team)
    current_user.admin? || (team.owners.exists?(current_user.id) &&
                            APP_CONFIG.enabled?("user_permission.manage_team"))
  end

  def can_create_team?
    current_user.admin? || APP_CONFIG.enabled?("user_permission.create_team")
  end

  # Render the namespace scope icon.
  def team_scope_icon(team)
    if team.team_users.enabled.count > 1
      icon = "fa-users"
      title = "Team"
    else
      icon = "fa-user"
      title = "Personal"
    end

    content_tag :i, "", class: "fa #{icon} fa-lg", title: title
  end

  # Render the team user role icon.
  def team_user_role_icon(team_user)
    icon = role_icon_class team_user.role

    content_tag :i, "", class: "fa #{icon} fa-lg", title: team_user.role.titleize
  end

  def role_icon_class(role)
    case role
    when "owner"
      "fa-male"
    when "contributor"
      "fa-exchange"
    when "viewer"
      "fa-eye"
    end
  end
end
