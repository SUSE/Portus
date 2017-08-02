# This is a rails runner that will print the status of Portus' database
# Possible outcomes:
#
#   * `DB_READY`: the database has been created and initialized
#   * `DB_EMPTY`: the database has been created but has not been initialized
#   * `DB_MISSING`: the database has not been created
#   * `DB_DOWN`: cannot connect to the database
#
# Originally included in the https://github.com/openSUSE/docker-containers
# repository under the same license.

require "portus/db"

puts Portus.database_exists?
