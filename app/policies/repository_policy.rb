# frozen_string_literal: true

class RepositoryPolicy
  attr_reader :user, :repository, :namespace

  def initialize(user, repository)
    @user = user
    @repository = repository
    @namespace = repository.namespace
  end

  def show?
    return namespace.visibility_public? unless @user

    @user.admin? ||
      namespace.visibility_public? ||
      namespace.visibility_protected? ||
      namespace.team.users.exists?(user.id)
  end

  def update?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || owner?
  end

  # Returns true if the repository can be destroyed.
  def destroy?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    is_contributor         = namespace.team.contributors.exists?(user.id)
    can_contributor_delete = APP_CONFIG["delete"]["contributors"] && is_contributor
    delete_enabled? && (@user.admin? || owner? || can_contributor_delete)
  end

  def owner?
    namespace.team.owners.exists?(user.id)
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

  protected

  # Returns true if delete is enabled
  def delete_enabled?
    APP_CONFIG.enabled?("delete")
  end
end
