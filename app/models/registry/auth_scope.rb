# Registry::AuthScope parses the scope string so it can be used afterwards for
# the "registry" type.
class Registry::AuthScope < Portus::AuthScope
  def resource
    reg = Registry.find_by(hostname: @registry.hostname)
    if reg.nil?
      Rails.logger.debug("No hostname matching #{@registry.hostname}, testing external_hostname")
      reg = Registry.find_by(external_hostname: @registry.hostname)
    end
    raise ResourceNotFound, "Could not find registry #{@registry.hostname}" if reg.nil?
    reg
  end

  def scopes
    catalog? ? ["all"] : []
  end

  private

  # Returns true if the given scope string corresponds to the /v2/_catalog
  # endpoint.
  def catalog?
    @resource_name == "catalog" && @actions[0] == "*"
  end
end
