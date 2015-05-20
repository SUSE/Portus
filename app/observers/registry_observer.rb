class RegistryObserver < ActiveRecord::Observer

  def after_create(registry)
    registry.create_global_namespace!
  end

end
