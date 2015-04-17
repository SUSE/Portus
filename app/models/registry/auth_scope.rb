class Registry::AuthScope

  class ResourceIsNotDefined < StandardError; end
  class ResourceIsNotFound < StandardError; end

  attr_accessor :resource, :actions, :resource_type

  def initialize(scope_string)
    @scope_string = scope_string
    parse_scope_string!
  end

  def resource
    raise ResourceIsNotDefined unless(klass = Object.const_get(@resource_type.capitalize) rescue nil)
    raise ResourceIsNotFound unless (found_resource = klass.find_by(name: @resource_name))
    found_resource
  end

  private

  def parse_scope_string!
    @resource_type    = requested_resource_type
    @resource_name    = requested_resource_name
    @actions          = requested_actions
  end

  def requested_resource_type
    @scope_string.split(':')[0]
  end

  def requested_resource_name
    @scope_string.split(':')[1].split('/').first
  end

  def requested_actions
    @scope_string.split(':')[2].split(',')
  end

end
