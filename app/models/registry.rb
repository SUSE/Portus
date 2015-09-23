# Registry holds data regarding the registries registered in the Portus
# application.
#
# NOTE: currently only one Registry is allowed to exist in the database. This
# might change in the future.
class Registry < ActiveRecord::Base
  has_many :namespaces

  validates :name, presence: true, uniqueness: true
  validates :hostname, presence: true, uniqueness: true
  validates :use_ssl, inclusion: [true, false]

  # Creates a global namespace owned by this registry. This method is called
  # whenever a new registry is saved.
  def create_global_namespace!
    team = Team.create(
      name:   Namespace.sanitize_name(hostname),
      owners: User.where(admin: true),
      hidden: true)
    Namespace.create!(
      name:     Namespace.sanitize_name(hostname),
      registry: self,
      public:   true,
      global:   true,
      team:     team)
  end

  # Returns the global namespace owned by this registry.
  def global_namespace
    Namespace.find_by(registry: self, global: true)
  end

  # Returns a registry client based on this registry that authenticates with
  # the credentials of the "portus" user.
  def client
    Portus::RegistryClient.new(hostname, use_ssl)
  end

  # Find the registry for the given push event.
  def self.find_from_event(event)
    registry = Registry.find_by(hostname: event["request"]["host"])
    if registry.nil?
      logger.info("Ignoring event coming from unknown registry
                  #{event["request"]["host"]}")
    end
    registry
  end

  # Fetch the information regarding a namespace on this registry for the given
  # event. If no namespace was found, then it returns nil. Otherwise, it
  # returns three values:
  #   - A Namespace object.
  #   - A String containing the name of the repository.
  #   - A String containing the name of the tag.
  def get_namespace_from_event(event)
    repo = event["target"]["repository"]
    if repo.include?("/")
      namespace_name, repo = repo.split("/", 2)
      namespace = namespaces.find_by(name: namespace_name)
    else
      namespace = global_namespace
    end

    if namespace.nil?
      logger.error "Cannot find namespace #{namespace_name} under registry #{hostname}"
      return
    end

    tag_name = get_tag_from_manifest(event["target"])
    return if tag_name.nil?

    [namespace, repo, tag_name]
  end

  protected

  # Fetch the tag of the image contained in the current event. The Manifest API
  # is used to fetch it, thus the repo name and the digest are needed (and
  # they are contained inside the event's target).
  #
  # Returns the name of the tag if found, nil otherwise.
  def get_tag_from_manifest(target)
    man = client.manifest(target["repository"], target["digest"])
    man["tag"]

  rescue
    logger.error("Could not fetch the tag for target #{target}.")
  end
end
