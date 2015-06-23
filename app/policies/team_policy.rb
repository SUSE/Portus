class TeamPolicy
  attr_reader :user, :team

  def initialize(user, team)
    fail Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @team = team
  end

  def member?
    user.admin? || @team.users.exists?(user.id)
  end

  alias_method :show?, :member?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.teams.where(hidden: false)
    end
  end
end
