module CommentsHelper
  # Return true if current_user has permission to destroy a comment
  # Returns false otherwise
  def can_destroy_comment?(comment)
    CommentPolicy.new(current_user, comment).destroy?
  end
end
