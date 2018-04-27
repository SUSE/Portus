# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_repository

  # POST /repositories/1/comments
  # POST /repositories/1/comments.json
  def create
    @comment = @repository.comments.new(params.require(:comment).permit(:body))
    @comment.author = current_user
    authorize @comment

    respond_to do |format|
      if @comment.save
        @comment_serialized = API::Entities::Comments.represent(
          @comment,
          current_user: current_user,
          type:         :internal
        ).to_json

        format.json { render json: @comment_serialized }
      else
        format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1/comments/1
  # DELETE /repositories/1/comments/1.json
  def destroy
    @comment = @repository.comments.find(params[:id])
    authorize @comment
    @comment.destroy
    respond_with @comment
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end
end
