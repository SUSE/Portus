# frozen_string_literal: true

module Tags
  class DestroyService < ::BaseService
    attr_accessor :error

    def execute(tag)
      raise ActiveRecord::RecordNotFound if tag.nil?

      repository = tag.repository
      tag_destroyed = tag.delete_by_digest!(current_user)

      if tag_destroyed && repository.tags.empty?
        ::Repositories::DestroyService.new(current_user).execute(repository)
      else
        full_messages = !tag.errors.empty? && tag.errors.full_messages
        @error = full_messages || "Could not remove <strong>#{tag.name}</strong> tag"
      end

      tag_destroyed
    end
  end
end
