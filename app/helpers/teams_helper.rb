module TeamsHelper

  def is_owner?(team)
    team.owners.exists?(current_user.id)
  end

  def role_within_team(team)
    team.team_users.find_by(user_id: current_user.id).role
  end
end
