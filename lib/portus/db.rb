# TODO
module Portus
  def self.database_exists?
    ActiveRecord::Base.connection
    if ActiveRecord::Base.connection.table_exists? "schema_migrations"
      "DB_READY"
    else
      "DB_EMPTY"
    end
  rescue ActiveRecord::NoDatabaseError
    "DB_MISSING"
  rescue Mysql2::Error
    "DB_DOWN"
  end
end
