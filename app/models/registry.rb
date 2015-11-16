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

  # On create, make sure that all the needed namespaces are in place.
  after_create :create_namespaces!

  # Today the data model supports many registries
  # however Portus just supports on Registry
  # therefore to avoid confusion, define just one way
  # to ask for the registy
  def self.get
    Registry.first
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

  # Checks whether this registry is reachable. If it is, then an empty string
  # is returned. Otherwise a string will be returned containing the reasoning
  # of the reachability failure.
  def reachable?
    msg = ""

    begin
      r = client.reachable?

      # At this point, !r is only possible if the returned code is 404, which
      # according to the documentation we have to assume that the registry is
      # not implementing the v2 of the API.
      return "Error: registry does not implement v2 of the API." unless r
    rescue Errno::ECONNREFUSED, SocketError
      msg = "Error: connection refused. The given registry is not available!"
    rescue Errno::ETIMEDOUT, Net::OpenTimeout
      msg = "Error: connection timed out. The given registry is not available!"
    rescue Net::HTTPBadResponse
      if use_ssl
        msg = "Error: there's something wrong with your SSL configuration."
      else
        msg = "Error: not using SSL, but the given registry does use SSL."
      end
    rescue OpenSSL::SSL::SSLError
      if use_ssl
        msg = "Error: using SSL, but the given registry is not using SSL."
      else
        msg = "Error: there's something wrong with your SSL configuration."
      end
    rescue StandardError => e
      # We don't know what went wrong :/
      logger.info "Registry not reachable: #{e.inspect}"
      msg = "Error: something went wrong. Check your configuration."
    end
    msg
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

  rescue StandardError => e
    logger.info("Could not fetch the tag for target #{target}")
    logger.info("Reason: #{e.message}")
    nil
  end

  # Create the global namespace for this registry and create the personal
  # namespace for all the existing users.
  def create_namespaces!
    count = Registry.count

    # Create the global team/namespace.
    team = Team.create(
      name:   "portus_global_team_#{count}",
      owners: User.where(admin: true),
      hidden: true)
    Namespace.create!(
      name:        "portus_global_namespace_#{count}",
      registry:    self,
      public:      true,
      global:      true,
      description: "The global namespace for the registry #{Registry.name}.",
      team:        team)

    # TODO: change code once we support multiple registries
    User.find_each(&:create_personal_namespace!)
  end
end
