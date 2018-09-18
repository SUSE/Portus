# frozen_string_literal: true

namespace :portus do
  namespace :db do
    # Idea taken from Gitlab's lib/tasks/gitlab/db.rake.
    desc "Configures the database by either migrating or loading the schema and seeding if needed" \
         ". It will also create the database if it doesn't exist."
    task configure: :environment do
      begin
        connection   = ActiveRecord::Base.connection
        only_migrate = connection.tables.count > 1
      rescue ActiveRecord::NoDatabaseError
        Rails.logger.info "Database is missing! Creating..."
        Rake::Task["db:create"].invoke
      end

      if only_migrate
        Rails.logger.info "Performing pending migrations..."
        Rake::Task["db:migrate"].invoke
      else
        Rails.logger.info "Configuring database..."
        Rake::Task["db:schema:load"].invoke
        Rake::Task["db:seed"].invoke
      end
    end
  end
end
