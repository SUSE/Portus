class NamespacesController < ApplicationController
  include ChangeNameDescription

  before_action :set_namespace, only: [:change_visibility, :show, :update]

  after_action :verify_authorized, except: [:index, :typeahead]
  after_action :verify_policy_scoped, only: :index

  # GET /namespaces
  # GET /namespaces.json
  def index
    # TODO: remove this!
    if request.head?
      check_namespace_by_name if params[:name]
    else
      respond_to do |format|
        format.html { skip_policy_scope }
      end
    end
  end

  # GET /namespaces/1
  # GET /namespaces/1.json
  def show
    raise ActiveRecord::RecordNotFound if @namespace.portus?

    authorize @namespace
    @repositories = @namespace.repositories.page(params[:page])
    @namespace_serialized = API::Entities::Namespaces.represent(
      @namespace,
      current_user: current_user,
      type:         :internal
    ).to_json

    respond_with(@namespace)
  end

  # PATCH/PUT /namespace/1
  # PATCH/PUT /namespace/1.json
  def update
    p = params.require(:namespace).permit(:name, :description, :team)

    change_name_description(@namespace, :namespace, p)
    change_team(p)

    respond_to do |format|
      format.json do
        if @namespace.errors.any?
          render json: @namespace.errors.full_messages, status: :unprocessable_entity
        else
          render json: API::Entities::Namespaces.represent(
            @namespace,
            current_user: current_user,
            type:         :internal
          )
        end
      end
    end
  end

  # GET /namespace/typeahead/%QUERY
  def typeahead
    @query = params[:query]
    valid_teams = TeamUser.get_valid_team_ids(current_user.id)
    matches = Team.search_from_query(valid_teams, "#{@query}%").pluck(:name)
    matches = matches.map { |team| { name: ActionController::Base.helpers.sanitize(team) } }
    respond_to do |format|
      format.json { render json: matches.to_json }
    end
  end

  # PATCH/PUT /namespace/1/change_visibility.json
  def change_visibility
    authorize @namespace

    # Update the visibility if needed
    return if visibility_param == @namespace.visibility

    return unless @namespace.update_attributes(visibility: visibility_param)

    @namespace.create_activity :change_visibility,
      owner:      current_user,
      parameters: { visibility: @namespace.visibility }

    respond_to do |format|
      format.js { render :change_visibility }
      format.json { render json: @namespace }
    end
  end

  private

  def change_team(p)
    # Update the team if needed/authorized.
    return if p[:team].blank? || p[:team] == @namespace.team.name
    authorize @namespace, :change_team?

    @team = Team.find_by(name: p[:team])
    if @team.nil?
      @namespace.errors[:team_id] << "'#{p[:team]}' unknown."
    else
      @namespace.create_activity :change_team,
        owner:      current_user,
        parameters: { old: @namespace.team.id, new: @team.id }
      @namespace.update_attributes(team: @team)
    end
  end

  # Normalizes visibility parameter
  def visibility_param
    value = params[:visibility]
    value = "visibility_#{value}" unless value.start_with?("visibility_")
    value
  end

  # Checks if namespaces exists based on the name parameter.
  # Renders an empty response with 200 if exists or 404 otherwise.
  def check_namespace_by_name
    skip_policy_scope
    namespace = Namespace.find_by(name: params[:name])

    if namespace
      head :ok
    else
      head :not_found
    end
  end

  def set_namespace
    @namespace = Namespace.find(params[:id])
  end
end
