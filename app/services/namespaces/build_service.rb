# frozen_string_literal: true

module Namespaces
  class BuildService < ::BaseService
    def execute
      build_namespace unless params.empty?
    end

    private

    def build_namespace
      team = fetch_team
      namespace_params = params.merge(
        visibility: Namespace.visibilities[:visibility_private],
        registry:   Registry.get
      )
      team.namespaces.build(namespace_params)
    end

    def fetch_team
      team = Team.find_by(name: params[:team], hidden: false)
      params.delete(:team)
      raise ActiveRecord::RecordNotFound if team.nil?

      team
    end
  end
end
