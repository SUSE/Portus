class RepositoriesController < ApplicationController
  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.all

    respond_with(@repositories)
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    @repository = Repository.find(params[:id])

    respond_with(@repository)
  end
end
