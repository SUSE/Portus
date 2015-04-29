class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @namespace = namespace
  end

  def pull?
    # All the members of the team have READ access
    namespace.team.users.exists?(user.id)
  end

  def push?
    # only owners and contributors have WRITE access
    namespace.team.owners.exists?(user.id) ||
    namespace.team.contributors.exists?(user.id)
  end

end
