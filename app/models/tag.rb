class Tag < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  validates :name,
            presence:   true,
            uniqueness: { scope: "repository_id" },
            format:     {
              with:    /\A[A-Za-z0-9_\.\-]{1,128}\Z/,
              message: "Only allowed letters: [A-Za-z0-9_.-]{1,128}" }
end
