class Admin::TeamsController < Admin::BaseController
  respond_to :html, :js

  def index
    @teams = Team.all_non_special.search(params[:filter]).page(params[:page])
  end
end
