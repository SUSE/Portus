class WebhookPolicy < NamespacePolicy
  attr_reader :webhook

  def initialize(user, webhook)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @webhook = webhook

    @namespace = webhook.namespace
  end

  def toggle_enabled?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    user.admin? || namespace.team.owners.exists?(user.id)
  end

  alias_method :destroy?, :push?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        namespaces = Namespace
          .joins(team: [:team_users])
          .where(
            "(namespaces.public = :public OR team_users.user_id = :user_id) AND " \
            "namespaces.global = :global AND namespaces.name != :username",
            public: true, user_id: user.id, global: false, username: user.username)
          .pluk(:id)

        scope
          .includes(:headers, :deliveries)
          .where("namespace_id = ?", namespaces)
      end
    end
  end
end
