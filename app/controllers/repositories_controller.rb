class RepositoriesController < ApplicationController

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    @repository = Repository.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @repository }
    end
  end
end
