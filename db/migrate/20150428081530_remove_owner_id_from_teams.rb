class RemoveOwnerIdFromTeams < ActiveRecord::Migration[4.2]
  def change
    remove_column :teams, :owner_id, :integer
  end
end
