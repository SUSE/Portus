class AddRoleToTeamUser < ActiveRecord::Migration[4.2]
  def change
    add_column :team_users, :role, :integer, default: TeamUser.roles['viewer']
    remove_column :team_users, :owner
  end
end
