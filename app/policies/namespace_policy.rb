# frozen_string_literal: true

class NamespacePolicy
  attr_reader :user, :namespace

  def initialize(user, namespace)
    @user = user
    @namespace = namespace
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def pull?
    # If user is portus, it can pull anything
    return true if user&.portus?

    # Even non-logged in users can pull from a public namespace.
    return true if namespace.visibility_public?

    # From now on, all the others require to be logged in.
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    # Logged-in users can pull from a protected namespace even if they are
    # not part of the team.
    return true if namespace.visibility_protected?

    # All the members of the team have READ access or anyone if
    # the namespace is public
    # Everybody can pull from the global namespace
    namespace.global? || user.admin? || member?
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  alias show? pull?

  def push?
    # Only logged-in users can push.
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    policy = APP_CONFIG["user_permission"]["push_images"]["policy"]
    case policy
    when "allow-personal", "allow-teams", "admin-only"
      user.admin? || push_policy_allow?(policy)
    else
      Rails.logger.warn "Unknown push policy '#{policy}'"
      false
    end
  end

  def index?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || member?
  end

  def create?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    (APP_CONFIG.enabled?("user_permission.create_namespace") || user.admin?) && push?
  end

  def destroy?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    can_contributor_delete = APP_CONFIG["delete"]["contributors"] && contributor?
    delete_enabled? && (@user.admin? || owner? || can_contributor_delete)
  end

  # TODO: temporary fix for see #2123
  alias delete? push?

  def update?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    (user.admin? || (APP_CONFIG.enabled?("user_permission.manage_namespace") &&
                     owner?)) && push?
  end

  alias all? push?

  def change_visibility?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || (APP_CONFIG.enabled?("user_permission.change_visibility") &&
                    !namespace.global? && owner?)
  end

  # Only owners and admins can change the team ownership.
  def change_team?
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    user.admin? || (APP_CONFIG.enabled?("user_permission.manage_namespace") &&
                    owner?)
  end

  def owner?
    namespace.team.owners.exists?(user.id)
  end

  def contributor?
    namespace.team.contributors.exists?(user.id)
  end

  def viewer?
    namespace.team.viewers.exists?(user.id)
  end

  def member?
    namespace.team.users.exists?(user.id)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.not_portus
      else
        scope
          .joins(team: [:team_users])
          .where(
            "namespaces.visibility = :public OR namespaces.visibility = :protected " \
            "OR team_users.user_id = :user_id",
            public:    Namespace.visibilities[:visibility_public],
            protected: Namespace.visibilities[:visibility_protected],
            user_id:   user.id
          )
          .distinct
      end
    end
  end

  protected

  # Returns true if delete is enabled and delete is generally allowed for the
  # given namespace.
  def delete_enabled?
    APP_CONFIG.enabled?("delete") && !@namespace.global?
  end

  # Returns true if the given push policy allows the push. This method assumes
  # that the current user is not an admin.
  def push_policy_allow?(policy)
    if policy == "allow-personal"
      user.namespace.id == namespace.id
    elsif policy == "allow-teams"
      namespace.team.owners.exists?(user.id) ||
        namespace.team.contributors.exists?(user.id)
    else
      false
    end
  end
end
