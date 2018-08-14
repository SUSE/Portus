# frozen_string_literal: true

class RepositoryPolicy
  attr_reader :user, :repository

  def initialize(user, repository)
    @user = user
    @repository = repository
  end

  def show?
    return @repository.namespace.visibility_public? unless @user

    @user.admin? ||
      @repository.namespace.visibility_public? ||
      @repository.namespace.visibility_protected? ||
      @repository.namespace.team.users.exists?(user.id)
  end

  # Returns true if the repository can be destroyed.
  def destroy?
    NamespacePolicy.new(@user, @repository.namespace).destroy?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.nil?
        @scope
          .joins(namespace: { team: :users })
          .where("namespaces.visibility = :namespace_visibility",
                 namespace_visibility: Namespace.visibilities[:visibility_public])
          .distinct
      elsif user.admin?
        @scope.all
      else
        # Show repositories only if the repository is public or
        # the repository belongs to the current_user
        @scope
          .joins(namespace: { team: :users })
          .where("namespaces.visibility = :namespace_visibility OR " \
                 "users.id = :user_id",
                 namespace_visibility: Namespace.visibilities[:visibility_public],
                 user_id:              @user.id)
          .distinct
      end
    end
  end
end
