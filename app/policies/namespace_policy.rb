class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @namespace = namespace
  end

  def pull?
    push?
  end

  def push?
    namespace.team.users.exists?(user.id)
  end

end
