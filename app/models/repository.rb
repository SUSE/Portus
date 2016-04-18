# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  namespace_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  fulltext_index_repositories_on_name          (name)
#  index_repositories_on_name_and_namespace_id  (name,namespace_id) UNIQUE
#  index_repositories_on_namespace_id           (namespace_id)
#

class Repository < ActiveRecord::Base
  include PublicActivity::Common
  include SearchCop

  belongs_to :namespace
  has_many :tags, dependent: :delete_all
  has_many :stars, dependent: :delete_all
  has_many :comments, dependent: :delete_all

  # We don't validate the format because we get that from the registry, and
  # it's guaranteed to be well-formatted there.
  validates :name, presence: true, uniqueness: { scope: "namespace_id" }

  search_scope :search do
    attributes :name
    attributes namespace_name: "namespace.name"

    # TODO: (mssola): we are experiencing some issues with MariaDB's fulltext
    # support. Because of that, the following two options have been disabled
    # until we find a solution for it.
    # options :name, type: :fulltext
    # options :namespace_name, type: :fulltext
  end

  # Set this repo as starred for the given user if there was no star
  # associated. Otherwise, remove the star.
  def toggle_star(user)
    star = stars.find_by(user: user)
    star ? star.destroy : stars.create(user: user)
  end

  # Check if this repo has been starred by the given user.
  def starred_by?(user)
    stars.exists? user: user
  end

  # Returns an array of all the tags from this repository grouped by the
  # digest.
  def groupped_tags
    tags.group_by(&:digest).values.sort do |x, y|
      y.first.created_at <=> x.first.created_at
    end
  end

  # Handle a push event from the registry.
  def self.handle_push_event(event)
    registry = Registry.find_from_event(event)
    return if registry.nil?

    namespace, repo_name, tag_name = registry.get_namespace_from_event(event)
    return if namespace.nil?

    repository = Repository.add_repo(event, namespace, repo_name, tag_name)
    return if repository.nil?

    namespace.repositories << repository if namespace
    repository
  end

  # Handle a delete event.
  def self.handle_delete_event(event)
    registry = Registry.find_from_event(event)
    return if registry.nil?

    # Fetch the repo.
    ns, repo_name, = registry.get_namespace_from_event(event, false)
    repo = ns.repositories.find_by(name: repo_name)
    return if repo.nil?

    # Destroy tags and the repository if it's empty now.
    repo.tags.where(digest: event["target"]["digest"]).map(&:delete_and_update!)
    repo.destroy if !repo.nil? && repo.tags.empty?
  end

  # Add the repository with the given `repo` name and the given `tag`. The
  # actor is guessed from the given `event`.
  def self.add_repo(event, namespace, repo, tag)
    actor = User.find_from_event(event)
    return if actor.nil?

    # Get or create the repository as "namespace/repo". If both the repo and
    # the given tag already exists, return early.
    repository = Repository.find_by(namespace: namespace, name: repo)
    if repository.nil?
      repository = Repository.create(namespace: namespace, name: repo)
    elsif repository.tags.exists?(name: tag)
      return
    end

    digest = event.try(:[], "target").try(:[], "digest")
    tag = repository.tags.create(name: tag, author: actor, digest: digest)
    repository.create_activity(:push, owner: actor, recipient: tag)
    repository
  end

  # Create or update the given repository in JSON format. The given repository
  # follows the same JSON format as in the one used by the Catalog API.
  # Therefore, it's a hash with two keys:
  #   - name: the name of the repo to be created/updated.
  #   - tags: an array of strings with the actual tags of the repository.
  # This method will transparently create/remove the tags that the given
  # repository is supposed to have.
  #
  # Note that if the repo is said to be contained inside of a namespace that
  # does not really exist, then this method will do nothing.
  #
  # Returns the final repository object.
  def self.create_or_update!(repo)
    # If the namespace does not exist, get out.
    namespace, name = Namespace.get_from_name(repo["name"])
    return if namespace.nil?

    # The portus user is the author for the created tags.
    portus = User.find_by(username: "portus")

    # Add the needed tags.
    repository = Repository.find_or_create_by!(name: name, namespace: namespace)
    tags = repository.tags.pluck(:name)

    to_be_created_tags = repo["tags"] - tags
    to_be_deleted_tags = tags - repo["tags"]

    client = Registry.get.client
    to_be_created_tags.each do |tag|
      # Try to fetch the manifest digest of the tag.
      begin
        digest = client.manifest(name, tag, true)
      rescue
        digest = ""
      end

      Tag.create!(name: tag, repository: repository, author: portus, digest: digest)
      logger.tagged("catalog") { logger.info "Created the tag '#{tag}'." }
    end

    # Finally remove the tags that are left and return the repo.
    repository.tags.where(name: to_be_deleted_tags).find_each(&:delete_and_update!)
    repository.reload
  end
end
