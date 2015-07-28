class RepositoriesController < ApplicationController
  before_action :set_repository, only: [:show, :star, :unstar]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.all

    respond_with(@repositories)
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    respond_with(@repository)
  end

  # POST /repositories/1/star
  # POST /repositories/1/star.json
  def star
    @repository.star current_user
    respond_to do |format|
      format.html { redirect_to(repository_path(@repository)) }
      format.json { render json: @repository }
      format.js   {}
    end
  end

  # POST /repositories/1/unstar
  # POST /repositories/1/unstar.json
  def unstar
    @repository.unstar current_user
    respond_to do |format|
      format.html { redirect_to(repository_path(@repository)) }
      format.json { render json: @repository }
      format.js   {}
    end
  end

  def set_repository
    @repository = Repository.find(params[:id])
  end
end
