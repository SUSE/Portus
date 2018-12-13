# frozen_string_literal: true

module Teams
  class DestroyService < ::BaseService
    attr_accessor :error

    def execute(team, new_team = nil)
      raise ActiveRecord::RecordNotFound if team.nil?

      if new_team.present?
        migrate_namespaces!(team, new_team)
      else
        destroy_namespaces!(team)
      end

      return false if @error.present?

      destroy_team!(team)
    end

    private

    def destroy_team!(team)
      destroyed = team.delete_by!(current_user)
      return true if destroyed

      full_messages = !team.errors.empty? && team.errors.full_messages
      @error = full_messages || "Could not remove team"
      false
    end

    def migrate_namespaces!(team, new_team)
      svc = ::Teams::MigrationService.new(current_user)
      svc.execute(team, new_team)

      @error = svc.error if svc.error.present?
    end

    def destroy_namespaces!(team)
      return true if team.namespaces.empty?

      errors = {}

      team.namespaces.each do |n|
        svc = ::Namespaces::DestroyService.new(current_user)
        errors[n.name] = svc.error unless svc.execute(n)
      end

      @error = errors if errors.present?
    end
  end
end
