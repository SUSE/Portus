# frozen_string_literal: true

namespace :portus do
  namespace :db do
    desc "Drops the database and configures it again"
    task reset: :environment do
      Rake::Task["portus:db:drop_tables"].invoke
      Rake::Task["portus:db:configure"].invoke
    end

    # Code taken from Gitlab's lib/tasks/gitlab/db.rake.
    desc "Drops all tables"
    task drop_tables: :environment do
      connection = ActiveRecord::Base.connection

      # If MySQL, turn off foreign key checks
      connection.execute("SET FOREIGN_KEY_CHECKS=0") if ::Portus::DB.mysql?

      tables = connection.data_sources
      tables.delete "schema_migrations"
      # Truncate schema_migrations to ensure migrations re-run
      connection.execute("TRUNCATE schema_migrations")

      # Drop tables with cascade to avoid dependent table errors
      # PG: http://www.postgresql.org/docs/current/static/ddl-depend.html
      # MySQL: http://dev.mysql.com/doc/refman/5.7/en/drop-table.html
      # Add `IF EXISTS` because cascade could have already deleted a table.
      tables.each do |t|
        connection.execute("DROP TABLE IF EXISTS #{connection.quote_table_name(t)} CASCADE")
      end

      # If MySQL, re-enable foreign key checks
      connection.execute("SET FOREIGN_KEY_CHECKS=1") if ::Portus::DB.mysql?
    rescue ActiveRecord::NoDatabaseError
      Rails.logger.info "Not dropping tables because database is not available..."
    end

    # Idea taken from Gitlab's lib/tasks/gitlab/db.rake.
    desc "Configures the database by either migrating or loading the schema and seeding if needed" \
         ". It will also create the database if it doesn't exist."
    task configure: :environment do
      begin
        connection   = ActiveRecord::Base.connection
        only_migrate = connection.data_sources.count > 1
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
