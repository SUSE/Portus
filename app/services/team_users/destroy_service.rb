# frozen_string_literal: true

module TeamUsers
  class DestroyService < ::TeamUsers::BaseService
    def execute(team_user)
      return false if team_user.nil?
      return false unless owners_remaining?(team_user)

      destroyed = team_user.destroy
      create_activity!(team_user) if destroyed
      destroyed
    end

    private

    def create_activity!(team_user)
      team_user.create_activity!(:remove_member, current_user,
                                 team_user: team_user.user.username,
                                 team:      team_user.team.name)
    end
  end
end
