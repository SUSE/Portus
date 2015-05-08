module TeamsHelper

  def is_team_owner?(team)
    team.owners.exists?(current_user.id)
  end

  def role_within_team(team)
    team_user = team.team_users.find_by(user_id: current_user.id)
    if team_user
      team_user.role.titleize
    else
      # That happens when the admin user access a team he's not part of
      '-'
    end
  end
end
