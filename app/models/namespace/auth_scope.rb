class Namespace::AuthScope

  class ResourceIsNotFound < StandardError; end

  attr_accessor :resource, :actions, :resource_type, :resource_name

  def initialize(registry, scope_string)
    @scope_string = scope_string
    @registry = registry
    parse_scope_string!
  end

  def resource
    if @namespace_name.blank?
      found_resource = @registry.namespaces.find_by(global: true)
    else
      found_resource = @registry.namespaces.find_by(name: @namespace_name)
    end

    if found_resource.nil?
      Rails.logger.warn "Namespace::AuthScope - Cannot find namespace with name #{@namespace_name}"
      raise ResourceIsNotFound
    end
    found_resource
  end

  private

  def parse_scope_string!
    @resource_type    = @scope_string.split(':')[0]
    @resource_name    = @scope_string.split(':')[1]
    @namespace_name   = requested_resource_namespace_name
    @actions          = requested_actions
  end

  def requested_resource_namespace_name
    if @resource_name.include?('/')
      @resource_name.split('/').first
    else
      nil
    end
  end

  def requested_actions
    @scope_string.split(':')[2].split(',')
  end

end
