# frozen_string_literal: true

class RepositoriesController < ApplicationController
  include WithPagination
  include WithOrdering

  before_action :set_repository, only: %i[show toggle_star]

  # GET /repositories/team
  def team_repositories
    @team_repositories = Repository
                         .joins(namespace: { team: :users })
                         .where("users.id = :user_id", user_id: current_user.id)

    render json: serialize_repositories(paginate(order(@team_repositories)))
  end

  # GET /repositories/other
  def other_repositories
    @team_repositories = Repository
                         .joins(namespace: { team: :users })
                         .select(:id)
                         .where("users.id = :user_id", user_id: current_user.id)
    @other_repositories = policy_scope(Repository).where.not(id: @team_repositories.map(&:id))

    render json: serialize_repositories(paginate(order(@other_repositories)))
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    authorize @repository
    @tags = @repository.groupped_tags
    @repository_comments = @repository.comments.all

    @repository_serialized = serialize_repositories(@repository).to_json
    @comments_serialized = API::Entities::Comments.represent(
      @repository.comments.all,
      current_user: current_user,
      type:         :internal
    ).to_json
    respond_with(@repository)
  end

  # POST /repositories/toggle_star
  def toggle_star
    respond_to do |format|
      if @repository.toggle_star(current_user)
        @repository_serialized = serialize_repositories(@repository).to_json
        format.json { render json: @repository_serialized }
      else
        format.json { render json: @repository.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  protected

  def set_repository
    @repository = Repository.find(params[:id])
  end

  def serialize_repositories(repositories)
    API::Entities::Repositories.represent(
      repositories,
      current_user: current_user,
      type:         :internal
    )
  end
end
