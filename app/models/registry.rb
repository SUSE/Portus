class Registry < ActiveRecord::Base
  extend Memoist
  has_many :namespaces
  validates :name, presence: true, uniqueness: true
  validates :hostname, presence: true, uniqueness: true
  validates :use_ssl, presence: true



  def create_global_namespace!
    team = Team.create(
      name: Namespace.sanitize_name(hostname),
      owners: User.where(admin: true),
      hidden: true)
    Namespace.create!(
      name: Namespace.sanitize_name(hostname),
      registry: self,
      public: true,
      global: true,
      team: team)
  end

  def global_namespace
    Namespace.find_by(registry: self, global: true)
  end

  # Find the registry for the given push event.
  def self.find_from_event(event)
    registry = Registry.find_by(hostname: event['request']['host'])
    if registry.nil?
      logger.info("Ignoring event coming from unknown registry
                  #{event['request']['host']}")
    end
    registry
  end

  # Regular expression used to fetch the tag of an image.
  PUSH_EVENT_FIND_TOKEN_REGEXP = %r{manifests/(?<tag>.*)$}

  # Fetch the information regarding a namespace on this registry for the given
  # event. If no namespace was found, then it returns nil. Otherwise, it
  # returns three values:
  #   - A Namespace object.
  #   - A String containing the name of the repository.
  #   - A String containing the name of the tag.
  def get_namespace_from_event(event)
    if event['target']['repository'].include?('/')
      namespace_name, repo_name = event['target']['repository'].split('/', 2)
      namespace = namespaces.find_by(name: namespace_name)
    else
      repo_name = event['target']['repository']
      namespace = global_namespace
    end

    if namespace.nil?
      logger.error "Cannot find namespace #{namespace_name} under registry #{hostname}"
      return
    end

    match = PUSH_EVENT_FIND_TOKEN_REGEXP.match(event['target']['url'])
    if match
      tag_name = match['tag']
    else
      logger.error("Cannot find tag inside of event url: #{event['target']['url']}")
      return
    end

    [namespace, repo_name, tag_name]
  end
end
