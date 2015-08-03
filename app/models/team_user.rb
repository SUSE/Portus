# Class describing a member of a team

# Meaning of the role column:
#   * viewer: has RO access to the namespaces associated with the team
#   * contributor: has RW access to the namespaces associated with the team
#   * owner: like contributor, but can also manage the team
class TeamUser < ActiveRecord::Base
  enum role: [:viewer, :contributor, :owner]

  scope :enabled, -> { joins(:user).where("users.enabled" => true) }

  validates :team, presence: true
  validates :user, presence: true, uniqueness: { scope: :team }

  belongs_to :team
  belongs_to :user
end
