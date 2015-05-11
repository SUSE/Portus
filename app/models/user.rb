class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [ :username ]

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9]{4,30}\Z/,
                                 message: 'Accepted format: "\A[a-z0-9]{4,30}\Z"' }

  has_many :team_users
  has_many :teams, through: :team_users

  def create_personal_team!
    if Team.find_by(name: username).nil?
      Team.create!(name: username, owners: [self])
    end
  end
end
