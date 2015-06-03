class RegistryObserver < ActiveRecord::Observer

  def after_create(registry)
    registry.create_global_namespace!

    # Now it is possible to create the private namespaces
    # of all the users that signed into portus _before_
    # the 1st registry was created
    # TODO: change code once we support multiple registries
    User.all.each(&:create_personal_namespace!)
  end

end
