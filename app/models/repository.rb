class Repository < ActiveRecord::Base
  belongs_to :namespace
  has_many :tags

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
      logger.error "Cannot find registry with hostname #{event['request']['host']}"
      return
    end

    namespace = registry.namespaces.find_by(name: namespace_name)
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
    repository.tags.where(name: tag_name).first_or_create(name: tag_name)

    namespace.repositories << repository if namespace
    repository
  end

end
