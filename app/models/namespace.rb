# == Schema Information
#
# Table name: namespaces
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer
#  public      :boolean          default("0")
#  registry_id :integer
#  global      :boolean          default("0")
#
# Indexes
#
#  fulltext_index_namespaces_on_name         (name)
#  index_namespaces_on_name_and_registry_id  (name,registry_id) UNIQUE
#  index_namespaces_on_registry_id           (registry_id)
#  index_namespaces_on_team_id               (team_id)
#

class Namespace < ActiveRecord::Base
  include PublicActivity::Common

  has_many :repositories
  belongs_to :registry
  belongs_to :team

  validates :public, inclusion: { in: [true] }, if: :global?
  validates :name,
            presence:   true,
            uniqueness: { scope: "registry_id" },
            length:     { maximum: 255 },
            namespace:  true

  # From the given repository name that can be prefix by the name of the
  # namespace, returns two values:
  #   1. The namespace where the given repository belongs to.
  #   2. The name of the repository itself.
  def self.get_from_name(name)
    if name.include?("/")
      namespace, name = name.split("/", 2)
      namespace = Namespace.find_by(name: namespace)
    else
      namespace = Namespace.find_by(global: true)
    end
    [namespace, name]
  end

  # Returns a String containing the cleaned name for this namespace. The
  # cleaned name will be the registry's hostname if this is a global namespace,
  # or the name of the namespace itself otherwise.
  def clean_name
    global? ? registry.hostname : name
  end
end
