class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @namespace = namespace
  end

  def pull?
    # All the members of the team have READ access or anyone if
    # the namespace is public
    # Everybody can pull from the global namespace
    namespace.global? || user.admin? || namespace.public? || namespace.team.users.exists?(user.id)
  end

  def push?
    # only owners and contributors have WRITE access
    user.admin? ||
      namespace.team.owners.exists?(user.id) ||
      namespace.team.contributors.exists?(user.id)
  end

  def show?
    pull?
  end

  def create?
    push?
  end

  def toggle_public?
    !namespace.global? && (user.admin? || namespace.team.owners.exists?(user.id))
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
        .joins(team: [:team_users])
        .where(
          "(namespaces.public = :public OR team_users.user_id = :user_id) AND " \
          "namespaces.global = :global AND namespaces.name != :username",
          public: true, user_id: user.id, global: false, username: user.username)
        .distinct
    end
  end
end
