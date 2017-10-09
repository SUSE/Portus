module Namespaces
  class UpdateService < ::BaseService
    include ::Helpers::ChangeNameDescription

    def build
      @namespace = Namespace.find(params[:id])
    end

    def execute
      change_name_description(@namespace, :namespace, params[:namespace])
      change_team
    end

    def wants_to_change_team?
      p = params[:namespace]
      p[:team].blank? || p[:team] == @namespace.team.name
    end

    protected

    # Update the team if needed/authorized.
    def change_team
      return if wants_to_change_team?

      @team = Team.find_by(name: params[:namespace][:team])
      if @team.nil?
        @namespace.errors[:team] << "'#{params[:namespace][:team]}' unknown."
      else
        @namespace.create_activity :change_team,
                                   owner:      current_user,
                                   parameters: { old: @namespace.team.id, new: @team.id }
        @namespace.update_attributes(team: @team)
      end
    end
  end
end
