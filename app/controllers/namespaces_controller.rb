class NamespacesController < ApplicationController
  include ChangeNameDescription

  before_action :set_namespace, only: [:change_visibility, :show, :update]
  before_action :check_team, only: [:create]
  before_action :check_role, only: [:create]

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

    respond_with(@namespace)
  end

  # POST /namespace
  # POST /namespace.json
  def create
    @namespace = fetch_namespace
    authorize @namespace

    respond_to do |format|
      if @namespace.save
        @namespace.create_activity :create,
                                   owner:      current_user,
                                   parameters: { team: @namespace.team.name }
        @namespaces = policy_scope(Namespace)

        namespace_json = API::Entities::Namespaces.represent(
          @namespace,
          current_user: current_user,
          type:         :internal
        )

        format.js
        format.json { render json: namespace_json }
      else
        format.js { render :create, status: :unprocessable_entity }
        format.json { render json: @namespace.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /namespace/1
  # PATCH/PUT /namespace/1.json
  def update
    p = params.require(:namespace).permit(:name, :description, :team)
    change_name_description(@namespace, :namespace, p)

    # Update the team if needed/authorized.
    return if p[:team] == @namespace.team.name
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

  # Fetch the namespace to be created from the given parameters. Note that this
  # method assumes that the @team instance object has already been set.
  def fetch_namespace
    ns = params.require(:namespace).permit(:name, :description)

    @namespace = Namespace.new(
      team:       @team,
      name:       ns["name"],
      visibility: Namespace.visibilities[:visibility_private],
      registry:   Registry.get
    )
    @namespace.description = ns["description"] if ns["description"]
    @namespace
  end

  # Check that the given team exists and that is not hidden. This hook is used
  # only as a helper of the `create` method.
  def check_team
    @team = Team.find_by(name: params["namespace"]["team"], hidden: false)
    return unless @team.nil?

    @error = "Selected team does not exist."
    respond_to do |format|
      format.js { render :create, status: :not_found }
      format.json { render json: [@error], status: :not_found }
    end
  end

  def check_role
    return false if current_user.admin? ||
        @team.owners.exists?(current_user.id) ||
        @team.contributors.exists?(current_user.id)

    @error = "You are not allowed to create a namespace for the team #{@team.name}."
    respond_to do |format|
      format.js { render :create, status: :unauthorized }
      format.json { render json: [@error], status: :unauthorized }
    end
  end

  def set_namespace
    @namespace = Namespace.find(params[:id])
  end
end
