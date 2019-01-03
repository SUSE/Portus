# frozen_string_literal: true

module Repositories
  class UpdateService < ::BaseService
    def build
      return if params[:id].blank?

      @repository = Repository.find(params[:id])
    end

    def execute
      return if @repository.blank?

      @repository.update(params[:repository])
    end
  end
end
