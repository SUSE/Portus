# frozen_string_literal: true

module API
  module Helpers
    # Helpers of teams
    module Teams
      # Prettify the role of the given user within the given team. You can pass
      # the value to be returned if this user does not belong to the team with
      # the `empty` argument.
      def role_within_team(user, team, empty = nil)
        team_user = team.team_users.find_by(user_id: user.id)
        if team_user
          team_user.role.titleize
        else
          empty
        end
      end

      def can_manage_team?(team, user)
        TeamPolicy.new(user, team).update?
      end

      def can_destroy_team?(team, user)
        TeamPolicy.new(user, team).destroy?
      end
    end
  end
end
