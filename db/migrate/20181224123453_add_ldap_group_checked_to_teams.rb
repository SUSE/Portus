class AddLdapGroupCheckedToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :ldap_group_checked, :int, default: Team.ldap_statuses[:unchecked]
  end
end
