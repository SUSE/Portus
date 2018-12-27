# frozen_string_literal: true

module Repositories
  class DestroyService < ::BaseService
    attr_accessor :error

    def execute(repository)
      raise ActiveRecord::RecordNotFound if repository.nil?

      mark_for_deletion!(repository)
      tags_destroyed = destroy_tags(repository)
      return false unless tags_destroyed

      destroyed = repository.delete_by!(current_user)

      unless destroyed
        full_messages = !repository.errors.empty? && repository.errors.full_messages
        @error = full_messages || "Could not remove repository"
      end

      destroyed
    end

    private

    def mark_for_deletion!(repository)
      repository.tags.update_all(marked: true)
      repository.update(marked: true)
    end

    def destroy_tags(repository)
      repository.groupped_tags.map do |t|
        ::Tags::DestroyService.new(current_user).execute(t.first)
      end

      destroyed_tags = repository.reload.tags.none?
      unless destroyed_tags
        remaining_tags = repository.tags.pluck(:name).join(", ")
        @error = "Could not remove repository: could not remove #{remaining_tags} tag(s)"
      end

      destroyed_tags
    end
  end
end
