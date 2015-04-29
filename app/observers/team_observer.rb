class TeamObserver < ActiveRecord::Observer

  def after_create(team)
    team.create_team_namespace!
  end

end
