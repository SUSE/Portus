class Team < ActiveRecord::Base

  belongs_to :owner, class_name: User
  has_many :namespaces

  validates :name, :owner, presence: true

  has_many :team_users
  has_many :users, through: :team_users

end
