# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show toggle_star]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = policy_scope(Repository)
    @repositories_serialized = API::Entities::Repositories.represent(
      @repositories,
      current_user: current_user,
      type:         :internal
    ).to_json
    @team_repositories = Repository
                         .joins(namespace: { team: :users })
                         .where("users.id = :user_id", user_id: current_user.id)
                         .map(&:full_name)
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    authorize @repository
    @tags = @repository.groupped_tags
    @repository_comments = @repository.comments.all
    respond_with(@repository)
  end

  # POST /repositories/toggle_star
  def toggle_star
    @repository.toggle_star current_user
    render template: "repositories/star", locals: { user: current_user }
  end

  protected

  def set_repository
    @repository = Repository.find(params[:id])
  end
end
