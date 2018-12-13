# frozen_string_literal: true

module Teams
  class MigrationService < ::BaseService
    attr_accessor :error

    def execute(team, new_team)
      raise ActiveRecord::RecordNotFound if team.nil? || new_team.nil?

      return false if team.namespaces.empty?

      migrate_namespaces!(team, new_team)
    end

    private

    def migrate_namespaces!(team, new_team)
      updated = team.namespaces.update_all(team_id: new_team.id)
      create_activity!(team, new_team) if updated

      return true if updated

      full_messages = !team.errors.empty? && team.errors.full_messages
      @error = full_messages || "Could not migrate namespaces"
      false
    end

    def create_activity!(team, new_team)
      p = { old_team: team.name, team: new_team.name }
      new_team.create_activity(:migration, owner: current_user, parameters: p)
    end
  end
end
