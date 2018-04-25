# frozen_string_literal: true

module Teams
  class UpdateService < ::BaseService
    include ::Helpers::ChangeNameDescription

    def build
      @team = Team.find(params[:id])
    end

    def execute
      change_name_description(@team, :team, params[:team], team: @team.name)
    end
  end
end
