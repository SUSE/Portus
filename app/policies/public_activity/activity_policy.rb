class PublicActivity::ActivityPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # Show Team events only if user is a member of the team
      team_activities = @scope
        .joins("INNER JOIN teams ON activities.trackable_id = teams.id " \
               "INNER JOIN team_users ON teams.id = team_users.team_id")
        .where("activities.trackable_type = ? AND team_users.user_id = ?",
               "Team", user.id)

      # Show Namespace events only if user is a member of the team controlling
      # the namespace or if the event is a public <-> private switch.
      namespace_activities = @scope
        .joins("INNER JOIN namespaces ON activities.trackable_id = namespaces.id " \
               "INNER JOIN teams ON teams.id = namespaces.team_id " \
               "INNER JOIN team_users ON teams.id = team_users.team_id")
        .where("activities.trackable_type = ? AND " \
               "(team_users.user_id = ? OR activities.key = ? OR activities.key = ?)",
               "Namespace", user.id, "namespace.public", "namespace.private")

      # Show tag events for repositories inside of namespaces controller by
      # a team the user is part of, or tags part of public namespaces.
      repository_activities = @scope
        .joins("INNER JOIN repositories ON activities.trackable_id = repositories.id " \
               "INNER JOIN namespaces ON namespaces.id = repositories.namespace_id " \
               "INNER JOIN teams ON namespaces.team_id = teams.id " \
               "INNER JOIN team_users ON teams.id = team_users.team_id")
        .where("activities.trackable_type = ? AND " \
               "(team_users.user_id = ? OR namespaces.public = ?)",
               "Repository", user.id, true)

      team_activities.union_all(namespace_activities).union_all(repository_activities)
    end
  end
end
