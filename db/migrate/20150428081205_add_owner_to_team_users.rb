class AddOwnerToTeamUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :team_users, :owner, :boolean, default: false
  end
end
