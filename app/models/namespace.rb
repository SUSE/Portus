# frozen_string_literal: true

# == Schema Information
#
# Table name: namespaces
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer
#  registry_id :integer          not null
#  global      :boolean          default(FALSE)
#  description :text(65535)
#  visibility  :integer
#
# Indexes
#
#  index_namespaces_on_name_and_registry_id  (name,registry_id) UNIQUE
#  index_namespaces_on_registry_id           (registry_id)
#  index_namespaces_on_team_id               (team_id)
#

class Namespace < ApplicationRecord
  include PublicActivity::Common
  include SearchCop
  include ::Activity::Fallback

  search_scope :search do
    attributes :name, :description
  end

  # This regexp is extracted from the reference package of Docker Distribution
  # and it matches a valid namespace name.
  NAME_REGEXP = /\A[a-z0-9]+(?:[._\\-][a-z0-9]+)*\Z/.freeze

  # The maximum length of a namespace name.
  MAX_NAME_LENGTH = 255

  has_many :webhooks, dependent: :destroy
  has_many :repositories, dependent: :destroy
  belongs_to :registry
  belongs_to :team

  enum visibility: %i[visibility_private visibility_protected visibility_public]

  validate :global_namespace_cannot_be_private
  validates :name,
            presence:   true,
            uniqueness: { scope: "registry_id" },
            length:     { maximum: MAX_NAME_LENGTH },
            namespace:  true

  scope :not_portus, -> { where.not name: "portus" }

  # Returns true if this namespace belongs to the internal user "portus".
  def portus?
    name == "portus"
  end

  # Returns true if namespace is orphan (no public team assigned)
  def orphan?
    !global && team.name.include?("global_team")
  end

  # global_namespace_cannot_be_private adds an error and returns false if the
  # visibility of the global namespace is set to private. Otherwise, it returns
  # true. This function is used to validate the visibility.
  def global_namespace_cannot_be_private
    if global? && visibility_private?
      errors.add(:visibility, "global namespace cannot be private")
      return false
    end
    true
  end

  # From the given repository name that can be prefix by the name of the
  # namespace, returns two values:
  #   1. The namespace where the given repository belongs to.
  #   2. The name of the repository itself.
  # If a registry is provided, it will query it for the given repository name.
  def self.get_from_repository_name(repo_name, registry = nil, create_if_missing = false)
    if repo_name.include?("/")
      namespace_name, repo_name = repo_name.split("/", 2)
      namespace = get_non_global_namespace(namespace_name, registry)
      namespace = create_from_name!(namespace_name) if namespace.nil? && create_if_missing
    else
      namespace = get_global_namespace(registry)
    end
    [namespace, repo_name, registry]
  end

  # Returns the global namespace based on registry
  def self.get_global_namespace(registry = nil)
    if registry.nil?
      Namespace.find_by(global: true)
    else
      registry.namespaces.find_by(global: true)
    end
  end

  # Returns a non global namespace based on its name and registry
  def self.get_non_global_namespace(namespace_name, registry = nil)
    if registry.nil?
      Namespace.find_by(name: namespace_name)
    else
      registry.namespaces.find_by(name: namespace_name)
    end
  end

  # Creates an orphan namespace attached to the global registry and team
  # with private visibility.
  def self.create_from_name!(name)
    namespace = Namespace.new(
      name:       name,
      registry:   Registry.get,
      visibility: Namespace.visibilities[:visibility_private],
      team:       Team.global
    )

    namespace = ::Namespaces::CreateService.new(User.portus, namespace).execute

    return unless namespace.persisted?

    namespace
  end

  # Tries to transform the given name to a valid namespace name without
  # clashing with existent namespaces.
  # If the name cannot be turned into a valid namespace name,
  # then nil is returned.
  # If the name is valid, checks if it clashes with others namespaces and
  # finds one until it's not being used and returns it.
  def self.make_valid(name)
    # One common case is LDAP and case sensitivity. With this in mind, try to
    # downcase everything and see if now it's fine.
    name = name.downcase

    # Let's strip extra characters from the beginning and end.
    first = name.index(/[a-z0-9]/)
    return nil if first.nil?

    last = name.rindex(/[a-z0-9]/)
    str = name[first..last]

    # Replace weird characters with underscores.
    str = str.gsub(/[^[a-z0-9\\.\\-_]]/, "_")

    # Only one special character is allowed in between of alphanumeric
    # characters. Thus, let's merge multiple appearences into one on each case.
    # After that, the name should be fine, so let's trim it if it's too large.
    final = str.gsub(/[._\\-]{2,}/, "_")
    name = final[0..MAX_NAME_LENGTH]

    return nil if name !~ NAME_REGEXP

    # To avoid any name conflict we append an incremental number to the end
    # of the name returns it as the name that will be used on both Namespace
    # and Team on the User#create_personal_namespace! method
    increment = 0
    original_name = name
    while Namespace.exists?(name: name)
      name = "#{original_name}#{increment}"
      increment += 1
      break if increment > 1000
    end

    name
  end

  # Returns a String containing the cleaned name for this namespace. The
  # cleaned name will be the registry's hostname if this is a global namespace,
  # or the name of the namespace itself otherwise.
  def clean_name
    global? ? registry.hostname : name
  end

  # Tries to delete a namespace and, on success, it will create delete
  # activities and update related ones. This method assumes that all
  # repositories and tags under this namespace have already been destroyed.
  def delete_by!(actor)
    destroy ? create_delete_activities!(actor) : false
  end

  protected

  def create_delete_activities!(actor)
    # Set the namespace name in the parameters field.
    # TODO(2.5): this could be more performant in PostgreSQL if we used its
    # `jsonb_set` function. Plus, in Rails 5 there might be some improvements
    # that might help on this.
    ApplicationRecord.transaction do
      PublicActivity::Activity.where(trackable: self).find_each do |act|
        act.parameters[:namespace_name] = clean_name
        act.save
      end
    end

    fallback_activity(Registry, registry.id)

    # Add a "delete" activity"
    registry.create_activity(
      :delete,
      owner:      actor,
      recipient:  self,
      parameters: {
        namespace_name: clean_name,
        team_name:      team.name,
        registry_id:    registry.id
      }
    )
  end
end
