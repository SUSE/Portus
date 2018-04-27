# frozen_string_literal: true

module API
  module Helpers
    # Helpers of teams
    module Comments
      # Return true if current_user has permission to destroy a comment
      # Returns false otherwise
      def can_destroy_comment?(comment, user)
        CommentPolicy.new(user, comment).destroy?
      end
    end
  end
end
