class Star < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'

  validates :repository, presence: true
  validates :author, presence: true, uniqueness: { scope: :repository }
end
