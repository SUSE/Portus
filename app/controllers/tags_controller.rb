# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    @tag = Tag.includes(:repository, :namespace).find(params[:id])
    @repository = @tag.repository
    @namespace = @tag.repository.namespace
    authorize @tag

    @tag_serialized = API::Entities::Tags.represent(
      @tag,
      current_user: current_user,
      type:         :internal
    ).to_json
  end
end
