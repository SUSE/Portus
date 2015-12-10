class RepositoriesController < ApplicationController
  before_action :set_repository, only: [:show, :toggle_star]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = policy_scope(Repository).all
    respond_with(@repositories)
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    authorize @repository
    @tags = @repository.tags.order("created_at DESC")
    @repository_comments = @repository.comments.all
    respond_with(@repository)
  end

  # GET /repositories/new
  def new
    @repository = Repository.new
    @repository.namespace = Namespace.find(params[:namespace_id]) if params[:namespace_id]
    authorize(@repository) if @repository.namespace

    scope = NamespacePolicy::Scope.new(current_user, Namespace)
    scope.include_personal_namespace = true
    @namespaces = scope.resolve
    logger.debug(@namespaces.count)
  end

  # POST /repositories
  # POST /repositories.json
  def create
    @repository = Repository.new(create_params)
    authorize @repository

    if @repository.save
      flash[:notice] = "Automated repository created successfully!"
      @repository.create_activity(
        :create,
        owner:      current_user,
        parameters: { source_url: @repository.source_url })
      redirect_to @repository
    else
      flash[:alert] = @repository.errors.full_messages
      render "new"
    end
  end

  # GET /repositories/:id/edit
  def edit
    @repository = Repository.find(params[:id])

    authorize @repository
  end

  # PUT /repositories/1
  def update
    @repository = Repository.find(params[:id])
    authorize @repository

    old_source = @repository.source_url

    @repository.update_attributes(update_params)

    @repository.create_activity(
      :edit,
      owner:      current_user,
      parameters: {
        new_source: @repository.source_url,
        old_source: old_source
      }
    )
    redirect_to @repository, notice: "Repository updated successfully!"
  end

  # POST /repositories/toggle_star
  def toggle_star
    @repository.toggle_star current_user
    render template: "repositories/star", locals: { user: current_user }
  end

  def set_repository
    @repository = Repository.find(params[:id])
  end

  private

  def create_params
    permitted = [:name, :namespace_id, :source_url]
    params.require(:repository).permit(permitted)
  end

  def update_params
    permitted = [:source_url]
    params.require(:repository).permit(permitted)
  end
end
