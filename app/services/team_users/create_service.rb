# frozen_string_literal: true

module TeamUsers
  class CreateService < ::BaseService
    attr_accessor :team_user

    def initialize(current_user, team_user = nil)
      @current_user = current_user
      @team_user = team_user
    end

    def execute
      return if team_user.nil?

      create_activity! if team_user.save

      team_user
    end

    private

    def create_activity!
      team_user.create_activity!(:add_member, current_user,
                                 team_user: team_user.user.username,
                                 team:      team_user.team.name)
    end
  end
end
