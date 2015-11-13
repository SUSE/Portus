class TeamsController < ApplicationController
  include ChangeNameDescription

  before_action :set_team, only: [:show, :update, :typeahead]
  after_action :verify_policy_scoped, only: :index
  respond_to :js, :html

  # GET /teams
  def index
    @teams = policy_scope(Team).page(params[:page])
    respond_with(@teams)
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    authorize @team
    @team_users = @team.team_users.enabled.page(params[:users_page]).per(10)
    @team_namespaces = @team.namespaces.page(params[:namespaces_page]).per(15)
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

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    change_name_description(@team, :team)
  end

  # GET /teams/1/typeahead/%QUERY
  def typeahead
    authorize @team
    @query = params[:query]
    matches = User.search_from_query(@team.member_ids, "#{@query}%").pluck(:username)
    matches = matches.map { |user| { name: user } }
    respond_to do |format|
      format.json { render json: matches.to_json }
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
