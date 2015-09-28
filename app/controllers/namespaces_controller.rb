class NamespacesController < ApplicationController
  include ChangeDescription

  respond_to :html, :js
  before_action :set_namespace, only: [:toggle_public, :show, :update]
  before_action :check_team, only: [:create]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /namespaces
  # GET /namespaces.json
  def index
    @special_namespaces = Namespace.where(
      "global = ? OR namespaces.name = ?", true, current_user.username)
    @namespaces = policy_scope(Namespace).page(params[:page])

    respond_with(@namespaces)
  end

  # GET /namespaces/1
  # GET /namespaces/1.json
  def show
    authorize @namespace
    @repositories = @namespace.repositories.page(params[:page])

    respond_with(@namespace)
  end

  # POST /namespace
  # POST /namespace.json
  def create
    @namespace = Namespace.new(
      team:     @team,
      name:     params["namespace"]["namespace"],
      registry: Registry.first
    )
    authorize @namespace

    respond_to do |format|
      if @namespace.save
        @namespace.create_activity :create, owner: current_user
        @namespaces = policy_scope(Namespace)
        format.js { respond_with @namespace }
      else
        format.js { respond_with @namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /namespace/1
  # PATCH/PUT /namespace/1.json
  def update
    change_description(@namespace, :namespace)
  end

  # PATCH/PUT /namespace/1/toggle_public
  def toggle_public
    authorize @namespace

    @namespace.update_attributes(public: !(@namespace.public?))
    if @namespace.public?
      @namespace.create_activity :public, owner: current_user
    else
      @namespace.create_activity :private, owner: current_user
    end
    render template: "namespaces/toggle_public", locals: { namespace: @namespace }
  end

  private

  # Check that the given team exists and that is not hidden. This hook is used
  # only as a helper of the `create` method.
  def check_team
    @team = Team.find_by(name: params["namespace"]["team"], hidden: false)
    return unless @team.nil?

    @error = "Selected team does not exist."
    respond_to do |format|
      format.js { respond_with nil, status: :not_found }
    end
  end

  def set_namespace
    @namespace = Namespace.find(params[:id])
  end
end
