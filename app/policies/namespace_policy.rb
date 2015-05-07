class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @namespace = namespace
  end

  def pull?
    # All the members of the team have READ access or anyone if
    # the namespace is public
    namespace.public? || namespace.team.users.exists?(user.id)
  end

  def push?
    # only owners and contributors have WRITE access
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
    namespace.team.owners.exists?(user.id)
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
        .where('namespaces.public = ? OR team_users.user_id = ?',  true, user.id)
    end
  end


end
