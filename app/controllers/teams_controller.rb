# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :set_team, only: %i[show typeahead]
  after_action :verify_policy_scoped, only: :index

  # GET /teams
  def index
    @teams = policy_scope(Team)
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
    @available_roles = TeamUser.roles.keys.map(&:titleize).to_json
    @team_serialized = API::Entities::Teams.represent(
      @team,
      current_user: current_user,
      type:         :internal
    ).to_json
    @team_users_serialized = API::Entities::TeamMembers.represent(
      @team.team_users.enabled,
      current_user: current_user,
      type:         :internal
    ).to_json
    @team_namespaces_serialized = API::Entities::Namespaces.represent(
      @team.namespaces,
      current_user: current_user,
      type:         :internal
    ).to_json
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
    teams = params[:unscoped] == "true" ? Team.all : policy_scope(Team)
    teams = teams.where("name LIKE ?", query).pluck(:name)
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
