class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:username]

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9]{4,30}\Z/,
                                 message: 'Accepted format: "\A[a-z0-9]{4,30}\Z"' },
                       exclusion: { in: %w(portus),
                                    message: '%{value} is reserved.' }

  validate :private_namespace_available, on: :create

  has_many :team_users
  has_many :teams, through: :team_users

  def private_namespace_available
    return unless Namespace.exists?(name: username)
    errors.add(:username, 'cannot be used as name for private namespace')
  end

  def create_personal_namespace!
    # the registry is not configured yet, we cannot create the namespace
    return unless Registry.any?

    team = Team.find_by(name: username)
    if team.nil?
      team = Team.create!(name: username, owners: [self], hidden: true)
    end

    Namespace.find_or_create_by!(
      team: team,
      name: username,
      registry: Registry.last # TODO: fix once we handle more registries
    )
  end
end
