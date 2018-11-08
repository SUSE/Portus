class AddHiddenToTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :hidden, :boolean, default: false
  end
end
