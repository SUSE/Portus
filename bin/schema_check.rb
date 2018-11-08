# frozen_string_literal: true

db = /version: ([\d\_]+)/

mysql      = IO.read(Rails.root.join("db", "schema.mysql.rb")).scan(db).first.first
postgresql = IO.read(Rails.root.join("db", "schema.postgresql.rb")).scan(db).first.first

if mysql == postgresql
  Rails.logger.tagged(:schema_check) { Rails.logger.info "All fine" }
  exit 0
else
  Rails.logger.tagged(:schema_check) do
    Rails.logger.info "You are not using the same schema version for MySQL and PostgreSQL!"
  end
  exit 1
end
