module Namespaces
  class UpdateService < ::BaseService
    include ::Helpers::ChangeNameDescription

    # Builds the referenced namespace.
    def build
      @namespace = Namespace.find(params[:id])
    end

    # The `build` method should be called before calling this one.
    def execute
      ret = change_name_description(@namespace, :namespace, params[:namespace])
      wants_to_change_team? ? change_team : ret
    end

    # Returns true if the parameters imply a change of team. The `build` method
    # should be called before this one.
    def wants_to_change_team?
      p = params[:namespace]
      !p[:team].blank? && p[:team] != @namespace.team.name
    end

    protected

    # Update the team if needed/authorized.
    def change_team
      @team = Team.find_by(name: params[:namespace][:team])

      if @team.nil?
        @namespace.errors[:team] << "'#{params[:namespace][:team]}' unknown."
      else
        @namespace.create_activity :change_team,
                                   owner:      current_user,
                                   parameters: { old: @namespace.team.id, new: @team.id }
        @namespace.update_attributes(team: @team)
      end

      @team
    end
  end
end
