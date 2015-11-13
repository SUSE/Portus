class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    @user = user
    @namespace = namespace
  end

  def pull?
    # Even non-logged in users can pull from a public namespace.
    return true if namespace.public?

    # From now on, all the others require to be logged in.
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    # All the members of the team have READ access or anyone if
    # the namespace is public
    # Everybody can pull from the global namespace
    namespace.global? || user.admin? || namespace.team.users.exists?(user.id)
  end

  alias_method :show?, :pull?

  def push?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    # Only owners and contributors have WRITE access
    user.admin? ||
      namespace.team.owners.exists?(user.id) ||
      namespace.team.contributors.exists?(user.id)
  end

  alias_method :all?,       :push?
  alias_method :create?,    :push?
  alias_method :update?,    :push?

  def toggle_public?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
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
