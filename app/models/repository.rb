class Repository < ActiveRecord::Base
  include NameValidator
  include PublicActivity::Common
  include SearchCop

  belongs_to :namespace
  has_many :tags
  has_many :stars

  search_scope :search do
    attributes :name
    attributes namespace_name: 'namespace.name'

    # TODO: (mssola): we are experiencing some issues with MariaDB's fulltext
    # support. Because of that, the following two options have been disabled
    # until we find a solution for it.
    # options :name, type: :fulltext
    # options :namespace_name, type: :fulltext
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
end
