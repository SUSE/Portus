class Repository < ActiveRecord::Base
  include NameValidator
  include PublicActivity::Common
  include SearchCop

  belongs_to :namespace
  has_many :tags, dependent: :delete_all
  has_many :stars, dependent: :delete_all

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

  # Add the repository with the given `repo` name and the given `tag`. The
  # actor is guessed from the given `event`.
  def self.add_repo(event, namespace, repo, tag)
    actor = User.find_from_event(event)
    return if actor.nil?

    # Get or create the repository as "namespace/repo"
    repository = Repository.find_by(namespace: namespace, name: repo)
    if repository.nil?
      repository = Repository.create(namespace: namespace, name: repo)
    end

    tag = repository.tags.where(name: tag)
      .first_or_create(name: tag, author: actor)
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
  # Returns the final repository object.
  def self.create_or_update!(repo)
    namespace, name = Namespace.get_from_name(repo["name"])
    repository = Repository.find_or_create_by!(name: name, namespace: namespace)

    # Add the needed tags.
    tags = repository.tags.pluck(:name)
    repo["tags"].each do |tag|
      idx = tags.find_index { |t| t == tag }
      if idx
        tags.delete_at(idx)
      else
        Tag.create!(name: tag, repository: repository)
      end
    end

    # Finally remove the tags that are left and return the repo.
    Tag.where(name: tags).delete_all
    repository.reload
  end
end
