# Helper module for testing jQuery datatables
module Datatables
  def create_records(numberOf, symbol)
    str_symbol = symbol.to_s
    numberOf.times do
      if str_symbol == "team"
        create(symbol, owners: [user1])
      elsif str_symbol == "namespace"
        create(symbol, team: team1, registry: registry)
      elsif str_symbol == "user"
        create(:team_user, user: create(symbol), team: team1)
      elsif str_symbol == "repository"
        create(symbol, namespace: namespace1)
      end
    end
  end
end
RSpec.configure { |config| config.include Datatables, type: :feature }
