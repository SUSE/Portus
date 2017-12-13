# frozen_string_literal: true

module Teams
  class CreateService < ::BaseService
    def execute
      @team = Team.new(params)
      @team.owners << current_user

      create_activity! if @team.save

      @team
    end

    private

    def create_activity!
      @team.create_activity(:create,
                            owner:      current_user,
                            parameters: { team: @team.name })
    end
  end
end
