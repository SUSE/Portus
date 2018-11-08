# frozen_string_literal: true

class WebhookPolicy < NamespacePolicy
  attr_reader :webhook

  def initialize(user, webhook)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @webhook = webhook

    @namespace = webhook.namespace
  end

  def create?
    create_or_manage?("create")
  end

  def update?
    create_or_manage?("manage")
  end

  def show?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || namespace.team.users.exists?(user.id)
  end

  alias destroy? create?
  alias toggle_enabled? update?

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
                       "(namespaces.visibility = :public OR namespaces.visibility = :protected OR "\
                       "team_users.user_id = :user_id) AND namespaces.global = :global",
                       public: Namespace.visibilities[:visibility_public],
                       protected: Namespace.visibilities[:visibility_protected], user_id: user.id,
                       global: false
                     )
                     .pluck(:id)

        scope.includes(:headers, :deliveries).where(namespace: namespaces)
      end
    end
  end

  protected

  def create_or_manage?(perm)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || (APP_CONFIG.enabled?("user_permission.#{perm}_webhook") &&
      namespace.team.owners.exists?(user.id))
  end
end
