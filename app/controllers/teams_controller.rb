class TeamsController < ApplicationController
  before_action :set_team, only: [:show]
  after_action :verify_policy_scoped, only: :index
  respond_to :js, :html

  # GET /teams
  def index
    @teams = policy_scope(Team)
    respond_with(@teams)
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    authorize @team
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)
    @team.owners << current_user

    if @team.save
      @team.create_activity :create, owner: current_user
      respond_with(@team)
    else
      respond_with @team.errors, status: :unprocessable_entity
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
