# Registry::AuthScope parses the scope string so it can be used afterwards for
# the "registry" type.
class Registry::AuthScope
  # The given Registry was not found.
  class ResourceIsNotFound < StandardError; end

  attr_accessor :resource, :actions, :resource_type, :resource_name

  def initialize(registry, scope_string)
    @scope_string = scope_string
    @registry     = registry
    parse_scope_string!
  end

  # Returns the registry required by this scope.
  def resource
    reg = Registry.find_by(hostname: @registry.hostname)
    if reg.nil?
      Rails.logger.warn "Could not find registry #{@registry.hostname}"
      raise ResourceIsNotFound
    end
    reg
  end

  # Returns an array containing the scopes available for this registry object.
  def scopes
    return catalog? ? ["all"] : []
  end

  private

  # Returns true if the given scope string corresponds to the /v2/_catalog
  # endpoint.
  def catalog?
    @resource_name == "catalog" && @actions[0] == "*"
  end

  # Parses the @scope_string variable into the needed attributes.
  def parse_scope_string!
    parts = @scope_string.split(":", 3)
    @resource_type = parts[0]
    @resource_name = parts[1]
    @actions       = parts[2].split(",")
  end
end
