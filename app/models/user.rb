class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [ :username ]

  validates :username, presence: true, uniqueness: true

  has_many :team_users
  has_many :teams, through: :team_users

  def create_personal_namespace!
    team = Team.find_by(name: username)
    if team.nil?
      team = Team.create!(name: username, owners: [self])
    end
    Namespace.find_or_create_by!(team: team, name: username)
  end

  def personal_namespace
    Namespace.find_by!(name: username)
  end

end
