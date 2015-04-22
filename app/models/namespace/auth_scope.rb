class Namespace::AuthScope

  class ResourceIsNotFound < StandardError; end

  attr_accessor :resource, :actions, :resource_type, :resource_name

  def initialize(scope_string)
    @scope_string = scope_string
    parse_scope_string!
  end

  def resource
    raise ResourceIsNotFound unless (found_resource = Namespace.find_by(name: @namespace_name))
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
