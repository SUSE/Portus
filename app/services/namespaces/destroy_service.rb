# frozen_string_literal: true

module Namespaces
  class DestroyService < ::BaseService
    attr_accessor :error

    def execute(namespace)
      raise ActiveRecord::RecordNotFound if namespace.nil?

      attempt_destroy!(namespace)
    end

    protected

    # attempt_destroy! checks that there are no semantic errors (e.g. trying to
    # remove a personal namespace manually), then it removes repositories
    # depending on this namespace and finally it removes the namespace.
    #
    # If any of the aforementioned steps fail, it will return false while
    # setting the proper value to the `error` instance variable. Otherwise it
    # returns true.
    def attempt_destroy!(namespace)
      return false if personal_namespace?(namespace)
      return false unless destroy_repositories!(namespace)

      destroyed = namespace.delete_by!(current_user)
      return true if destroyed

      full_messages = !namespace.errors.empty? && namespace.errors.full_messages
      @error = full_messages || "Could not remove namespace"
      false
    end

    # Returns true if the given namespace is a personal namespace of some
    # user. If so, then it will also set the `error` instance variable
    # accordingly.
    def personal_namespace?(namespace)
      return false unless User.find_by(namespace: namespace)

      @error = "Cannot remove personal namespace"
      true
    end

    # Destroys the repositories of the given namespace and returns true on
    # success, false otherwise.
    def destroy_repositories!(namespace)
      errors = {}
      namespace.repositories.each do |r|
        svc = ::Repositories::DestroyService.new(current_user)
        errors[r.full_name.to_s] = svc.error unless svc.execute(r)
      end

      @error = errors unless errors.empty?
      errors.empty?
    end
  end
end
