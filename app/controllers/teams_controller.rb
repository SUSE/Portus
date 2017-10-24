class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :typeahead]
  after_action :verify_policy_scoped, only: :index

  # TODO: remove
  respond_to :js, :html

  # GET /teams
  def index
    @teams = policy_scope(Team).page(params[:page])
    @teams_serialized = API::Entities::Teams.represent(
      @teams,
      current_user: current_user,
      type:         :internal
    ).to_json
    respond_with(@teams)
  end

  # GET /teams/1
  # GET /teams/1.json
  # TODO: remove the JSON part in favor of the API
  def show
    raise ActiveRecord::RecordNotFound if @team.hidden?

    authorize @team
    @team_users = @team.team_users.enabled.page(params[:users_page]).per(10)
    @team_namespaces_serialized = API::Entities::Namespaces.represent(
      @team.namespaces,
      current_user: current_user,
      type:         :internal
    )
  end

  # GET /teams/1/typeahead/%QUERY
  def typeahead
    authorize @team
    @query = params[:query]
    matches = User.search_from_query(@team.member_ids, "#{@query}%").pluck(:username)
    matches = matches.map { |user| { name: ActionController::Base.helpers.sanitize(user) } }
    respond_to do |format|
      format.json { render json: matches.to_json }
    end
  end

  # GET /teams/typeahead/%QUERY
  def all_with_query
    query = "#{params[:query]}%"
    teams = policy_scope(Team).where("name LIKE ?", query).pluck(:name)
    matches = teams.map { |t| { name: ActionController::Base.helpers.sanitize(t) } }
    respond_to do |format|
      format.json { render json: matches.to_json }
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end
end
