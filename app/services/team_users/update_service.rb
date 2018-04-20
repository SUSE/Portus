# frozen_string_literal: true

module TeamUsers
  class UpdateService < ::TeamUsers::BaseService
    def execute(team_user)
      return false if team_user.nil?

      old_role = team_user.role

      if demoting_admin?(team_user)
        @message = "User cannot be demoted because it's a Portus admin"
        return false
      end

      updated = team_user.update(role: new_role) if owners_remaining?(team_user)

      create_activity!(team_user, old_role) if updated

      updated
    end

    private

    def new_role
      params[:role]
    end

    def create_activity!(team_user, old_role)
      team_user.create_activity!(:change_member_role, current_user,
                                 old_role:  old_role,
                                 new_role:  new_role,
                                 team:      team_user.team.name,
                                 team_user: team_user.user.username)
    end

    # Returns true if a Portus admin is going to be set a role other than owner.
    def demoting_admin?(team_user)
      team_user.user&.admin? && new_role != "owner"
    end
  end
end
