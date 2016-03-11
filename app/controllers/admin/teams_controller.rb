class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.all_non_special
  end
end
