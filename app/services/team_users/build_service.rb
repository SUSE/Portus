# frozen_string_literal: true

module TeamUsers
  class BuildService < ::BaseService
    def execute
      team_user = build_team_user unless params.empty?

      enforce_admin_owner!(team_user) unless team_user.nil?

      team_user
    end

    private

    # Always set role as owner if user is a Portus admin
    def enforce_admin_owner!(team_user)
      team_user[:role] = TeamUser.roles[:owner] if team_user.user&.admin?
    end

    def build_team_user
      team = fetch_team
      user = fetch_user
      TeamUser.new(user: user, team: team, role: params[:role])
    end

    def fetch_user
      user = User.find_by!(username: params[:user])
      params.delete(:user)
      user
    end

    def fetch_team
      Team.find_by!(id: params[:id], hidden: false)
    end
  end
end
