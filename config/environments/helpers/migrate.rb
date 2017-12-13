# frozen_string_literal: true

# TODO: remove this on the next version
def run_migration!(config)
  return if ENV["SKIP_MIGRATION"]

  config.after_initialize do
    begin
      ActiveRecord::Migrator.migrate(Rails.root.join("db", "migrate"), nil)
    rescue StandardError => e
      warn "Error running migration: #{e.message}"
    end
  end
end
