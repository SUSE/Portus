class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.all
  end
end
