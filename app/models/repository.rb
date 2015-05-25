class Repository < ActiveRecord::Base
  include PublicActivity::Common
  include SearchCop

  NAME_ALLOWED_CHARS = 'a-z0-9\-_'

  belongs_to :namespace
  has_many :tags

  validates :name,
            presence: true,
            uniqueness: { scope: 'namespace_id' },
            format: {
              with: /\A[#{NAME_ALLOWED_CHARS}]+\Z/,
              message: 'Only allowed letters: [a-z0-9-_]' }

  search_scope :search do
    attributes :name
    attributes namespace_name: 'namespace.name'

    options :name, type: :fulltext
    options :namespace_name, type: :fulltext
  end

  PUSH_EVENT_FIND_TOKEN_REGEXP = %r|manifests/(?<tag>.*)$|

  def self.handle_push_event(event)
    if event['target']['repository'].include?('/')
      namespace_name, repo_name = event['target']['repository'].split('/', 2)
    else
      repo_name = event['target']['repository']
    end

    match = PUSH_EVENT_FIND_TOKEN_REGEXP.match(event['target']['url'])
    if match
      tag_name = match['tag']
    else
      logger.error("Cannot find tag inside of event url: #{event['target']['url']}")
      return
    end

    registry = Registry.find_by(hostname: event['request']['host'])
    if registry.nil?
      logger.info("Ignoring event coming from unknown registry #{event['request']['host']}")
      return
    end

    if namespace_name
      namespace = registry.namespaces.find_by(name: namespace_name)
    else
      namespace = registry.global_namespace
    end

    if namespace.nil?
      logger.error "Cannot find namespace #{namespace_name} under registry #{registry.hostname}"
      return
    end

    actor = User.find_by(username: event['actor']['name'])
    if actor.nil?
      logger.error "Cannot find user #{event['actor']['name']}"
      return
    end

    repository = Repository.where(name: repo_name)
      .first_or_create(name: repo_name)
    tag = repository.tags.where(name: tag_name)
      .first_or_create(name: tag_name, author: actor)
    repository.create_activity(:push, owner: actor, recipient: tag)

    namespace.repositories << repository if namespace
    repository
  end

end
