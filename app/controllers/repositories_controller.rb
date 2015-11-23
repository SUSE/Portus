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
    respond_with(@repository)
  end

  # POST /repositories/toggle_star
  def toggle_star
    @repository.toggle_star current_user
    render template: "repositories/star", locals: { user: current_user }
  end

  def set_repository
    @repository = Repository.find(params[:id])
  end
end
