# frozen_string_literal: true

class TeamPolicy
  attr_reader :user, :team

  def initialize(user, team)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @team = team
  end

  def member?
    user.admin? || team.users.exists?(user.id)
  end

  def owner?
    user.admin? || team.owners.exists?(user.id)
  end

  def create?
    APP_CONFIG.enabled?("user_permission.create_team") || user.admin?
  end

  def update?
    (APP_CONFIG.enabled?("user_permission.manage_team") || user.admin?) && !team.hidden? && owner?
  end

  def destroy?
    can_contributor_delete = APP_CONFIG["delete"]["contributors"] && contributor?
    delete_enabled = APP_CONFIG.enabled?("delete")
    delete_enabled && !team.hidden? && (user.admin? || owner? || can_contributor_delete)
  end

  alias show? member?
  alias typeahead? owner?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        Team.all_non_special
      else
        user.teams.where(hidden: false)
      end
    end
  end
end
