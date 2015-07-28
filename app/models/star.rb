class Star < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user

  validates :repository, presence: true
  validates :user, presence: true, uniqueness: { scope: :repository }
end
