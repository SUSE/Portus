class Team < ActiveRecord::Base
  include PublicActivity::Common

  validates :name, :owners, presence: true

  has_many :namespaces

  has_many :team_users
  has_many :users, through: :team_users
  has_many :owners, -> { where 'team_users.role' => TeamUser.roles['owner'] },
    through: :team_users, source: :user
  has_many :contributors, -> { where 'team_users.role' => TeamUser.roles['contributor'] },
    through: :team_users, source: :user
  has_many :viewers, -> { where 'team_users.role' => TeamUser.roles['viewer'] },
    through: :team_users, source: :user

  before_create :downcase?

  def create_team_namespace!
    # TODO: change once we allow more registries to be handled by portus
    registry = Registry.first
    Namespace.find_or_create_by!(team: self,
                                 name: Namespace.sanitize_name(name),
                                 registry: registry)
  end

  private

  def downcase?
    name.downcase == name
  end

end
