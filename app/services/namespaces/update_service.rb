# frozen_string_literal: true

module Namespaces
  class UpdateService < ::BaseService
    include ::Helpers::ChangeNameDescription
    include ::Portus::Errors

    # Builds the referenced namespace.
    def build
      @namespace = Namespace.find(params[:id])
    end

    # The `build` method should be called before calling this one.
    def execute
      ret = change_name_description(@namespace, :namespace, params[:namespace])
      ret = wants_to_change_team? ? change_team : ret
      wants_to_change_visibility? ? change_visibility : ret
    end

    # Returns true if the parameters imply a change of team. The `build` method
    # should be called before this one.
    def wants_to_change_team?
      p = params[:namespace]
      p[:team].present? && p[:team] != @namespace.team.name
    end

    # Returns true if the given parameters hint that the visibility of the
    # namespace should be changed.
    #
    # It will raise a `::Portus::Errors::UnprocessableEntity` if the given
    # `visibility` parameter had an unknown value.
    def wants_to_change_visibility?
      p = params[:namespace]
      return false if p[:visibility].blank?

      given = visibility_from_params(p[:visibility])
      if given.nil?
        msg = "unknown visibility kind '#{p[:visibility]}'"
        raise ::Portus::Errors::UnprocessableEntity, msg
      end
      p[:visibility] != @namespace.visibility.to_s
    end

    protected

    # Returns the enum value from the passed parameter.
    def visibility_from_params(vis)
      Namespace.visibilities["visibility_#{vis}"]
    end

    # Update the team if needed/authorized.
    def change_team
      @team = Team.find_by(name: params[:namespace][:team])

      if @team.nil?
        msg = "unknown team '#{params[:namespace][:team]}'"
        raise ::Portus::Errors::NotFoundError, msg
      else
        p = { old: @namespace.team.id, new: @team.id }
        @namespace.create_activity :change_team, owner: current_user, parameters: p
        @namespace.update(team: @team)
      end

      @team
    end

    # Updates the visibility parameter with the given one and creates a
    # `change_visibility` activity.
    def change_visibility
      given = visibility_from_params(params[:namespace][:visibility]).to_i
      parameters = { visibility: params[:namespace][:visibility] }

      return unless @namespace.update(visibility: given)

      @namespace.create_activity :change_visibility, owner: current_user, parameters: parameters
    end
  end
end
