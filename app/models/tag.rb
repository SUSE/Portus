# A tag as defined by Docker. It belongs to a repository and an author. The
# name follows the format as defined in registry/api/v2/names.go from Docker's
# Distribution project. The default name for a tag is "latest".
class Tag < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  NAME_ALLOWED_CHARS = '[\w][\w.-]*'

  validates :name,
            uniqueness: { scope: "repository_id" },
            length:     { maximum: 128 },
            format:     {
              with:    /\A#{NAME_ALLOWED_CHARS}\Z/,
              message: "Only allowed letters: #{NAME_ALLOWED_CHARS}"
            }
end
