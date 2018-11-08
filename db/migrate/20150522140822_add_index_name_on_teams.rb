class AddIndexNameOnTeams < ActiveRecord::Migration[4.2]
  def change
    add_index :teams, :name, unique: true
  end
end
