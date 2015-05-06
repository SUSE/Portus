class NamespacesController < ApplicationController
  respond_to :html, :js
  before_action :set_namespace, only: [:toggle_public, :show]

  after_action :verify_authorized, :except => :index
  after_action :verify_policy_scoped, :only => :index

  # GET /namespaces
  # GET /namespaces.json
  def index
    @namespaces = policy_scope(Namespace)

    respond_with(@namespaces)
  end

  # GET /namespaces/1
  # GET /namespaces/1.json
  def show
    authorize @namespace
    respond_with(@namespace)
  end

  # POST /namespace
  # POST /namespace.json
  def create
    team = Team.find_by!(name: params['namespace']['team'])

    @namespace = Namespace.new(team: team, name: params['namespace']['namespace'])
    authorize @namespace

    respond_to do |format|
      if @namespace.save
        format.js { respond_with @namespace }
      else
        format.js {respond_with @namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /namespace/1/toggle_public
  def toggle_public
    authorize @namespace

    #authorize @namespace
    @namespace.update_attributes(public: !(@namespace.public?))
    render template: 'namespaces/toggle_public', locals: {namespace: @namespace}
  end

  private

  def set_namespace
    @namespace = Namespace.find(params[:id])
  end

end
