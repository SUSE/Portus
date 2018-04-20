# frozen_string_literal: true

module TeamsHelper
  def manage_teams_enabled?
    APP_CONFIG.enabled?("user_permission.manage_team")
  end

  def can_manage_team?(team)
    current_user.admin? || (team.owners.exists?(current_user.id) &&
                            manage_teams_enabled?)
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
end
