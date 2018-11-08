# frozen_string_literal: true

require "fileutils"
require "portus/db"

def link!(name)
  link   = Rails.root.join("db", "schema.rb")
  target = Rails.root.join("db", "schema.#{name}.rb")
  FileUtils.ln_s(target, link, force: true)

  Rails.logger.tagged(:schema) { Rails.logger.info "Selected the schema for #{name}" }
end

::Portus::DB.mysql? ? link!("mysql") : link!("postgresql")
