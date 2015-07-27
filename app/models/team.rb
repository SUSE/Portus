class Team < ActiveRecord::Base
  include PublicActivity::Common

  validates :name, presence: true, uniqueness: true
  validates :owners, presence: true
  has_many :namespaces

  has_many :team_users
  has_many :users, through: :team_users
  has_many :owners, -> { where 'team_users.role' => TeamUser.roles['owner'] },
    through: :team_users, source: :user
  has_many :contributors, -> { where 'team_users.role' => TeamUser.roles['contributor'] },
    through: :team_users, source: :user
  has_many :viewers, -> { where 'team_users.role' => TeamUser.roles['viewer'] },
    through: :team_users, source: :user

  # Returns all the teams that are not special. By special team we mean:
  #   - It's the global namespace (see: Registry#create_global_namespace!).
  #   - It's a personal namespace (see: User#create_personal_namespace!).
  def self.all_non_special
    # Right now, all the special namespaces are simply marked as hidden.
    Team.where(hidden: false)
  end
end
