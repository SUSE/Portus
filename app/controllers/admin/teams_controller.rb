class Admin::TeamsController < Admin::BaseController

  def index
    @teams = Team.all
    render template: 'teams/index'
  end

end
