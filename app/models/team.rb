# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hidden      :boolean          default(FALSE)
#  description :text(65535)
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#

class Team < ApplicationRecord
  include PublicActivity::Common
  include SearchCop
  include ::Activity::Fallback

  search_scope :search do
    attributes :name, :description
  end

  # Returns all the teams that are not special. By special team we mean:
  #   - It's the global namespace (see: Registry#create_namespaces!).
  #   - It's a personal namespace (see: User#create_personal_namespace!).
  #
  # Right now, all the special namespaces are simply marked as hidden.
  scope :all_non_special, -> { where(hidden: false) }

  validates :name, presence: true, uniqueness: true
  validates :owners, presence: true
  has_many :namespaces, dependent: :destroy

  has_many :team_users, dependent: :destroy
  has_many :users, through: :team_users
  has_many :owners, -> { merge TeamUser.owner },
           through: :team_users, source: :user
  has_many :contributors, -> { merge TeamUser.contributor },
           through: :team_users, source: :user
  has_many :viewers, -> { merge TeamUser.viewer },
           through: :team_users, source: :user

  # Returns all the member-IDs
  def member_ids
    team_users.pluck(:user_id)
  end

  # Tries to delete a team and, on success, it will create delete
  # activities and update related ones. This method assumes that all
  # namespaces, repositories and tags under this team have already
  # been destroyed.
  def delete_by!(actor)
    destroy ? create_delete_activities!(actor) : false
  end

  def create_delete_activities!(actor)
    registry = Registry.get

    fallback_activity(Registry, registry.id)

    # Add a "delete" activity
    registry.create_activity(:remove_team, owner: actor, parameters: { team: name })
  end

  # Returns the main global team
  def self.global
    find_by(name: "portus_global_team_1")
  end

  # Returns all teams whose name match the query
  def self.search_from_query(valid_teams, query)
    all_non_special.where(id: valid_teams).where(arel_table[:name].matches(query))
  end

  # Tries to transform the given name to a valid team name without
  # clashing with existent teams.
  # Checks if it clashes with others teams and finds one until it's not
  # being used and returns it.
  def self.make_valid(name)
    # To avoid any name conflict we append an incremental number to the end
    # of the name returns it as the name that will be used on both Namespace
    # and Team on the User#create_personal_namespace! method
    # TODO: workaround until we implement the namespace/team removal
    increment = 0
    original_name = name
    while Team.exists?(name: name)
      name = "#{original_name}#{increment}"
      increment += 1
    end

    name
  end
end
