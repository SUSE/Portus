# frozen_string_literal: true

# This is a rails runner that will print the status of Portus' database.
# Possible outcomes:
#
#   * `DB_READY`: the database has been created and initialized.
#   * `DB_EMPTY`: the database has been created but has not been initialized.
#   * `DB_MISSING`: the database has not been created.
#   * `DB_DOWN`: cannot connect to the database.
#   * `DB_UNKNOWN`: unknown error.

require "portus/db"

puts case Portus::DB.ping
     when :ready
       "DB_READY"
     when :empty
       "DB_EMPTY"
     when :missing
       "DB_MISSING"
     when :down
       "DB_DOWN"
     else
       "DB_UNKNOWN"
     end
