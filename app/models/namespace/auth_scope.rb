# Namespace::AuthScope parses the scope string for the "namespace" type.
class Namespace::AuthScope < Portus::AuthScope
  attr_accessor :resource, :actions, :resource_type, :resource_name

  def resource
    if @namespace_name.blank?
      found_resource = @registry.namespaces.find_by(global: true)
    else
      found_resource = @registry.namespaces.find_by(name: @namespace_name)
    end

    if found_resource.nil?
      Rails.logger.warn "Cannot find namespace with name #{@namespace_name}"
      raise ResourceNotFound
    end
    found_resource
  end

  protected

  # Re-implemented from Portus::AuthScope to deal with the name of the
  # namespace.
  def parse_scope_string!
    super
    @namespace_name = @resource_name.split("/").first
  end
end
