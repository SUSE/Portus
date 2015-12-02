class Comment < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :repository
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  validates :body, presence: true

  # Returns true if the user is the author of the comment
  def author?(user)
    user_id == user.id
  end
end
