class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [ :username ]

  validates :username, presence: true, uniqueness: true

  def create_personal_repository!
    team = Team.find_or_create_by!(name: username, owner: self)
    Repository.find_or_create_by!(team: team, name: username)
  end

end
