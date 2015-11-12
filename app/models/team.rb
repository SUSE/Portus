class Team < ActiveRecord::Base
  include PublicActivity::Common

  validates :name, presence: true, uniqueness: true
  validates :owners, presence: true
  has_many :namespaces

  has_many :team_users
  has_many :users, through: :team_users
  has_many :owners, -> { merge TeamUser.owner },
    through: :team_users, source: :user
  has_many :contributors, -> { merge TeamUser.contributor },
    through: :team_users, source: :user
  has_many :viewers, -> { merge TeamUser.viewer },
    through: :team_users, source: :user

  # Returns all the teams that are not special. By special team we mean:
  #   - It's the global namespace (see: Registry#create_namespaces!).
  #   - It's a personal namespace (see: User#create_personal_namespace!).
  def self.all_non_special
    # Right now, all the special namespaces are simply marked as hidden.
    Team.where(hidden: false)
  end

  # Returns all the member-IDs
  def member_ids
    team_users.pluck(:user_id)
  end
end
