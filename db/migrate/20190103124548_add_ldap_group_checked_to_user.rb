class AddLdapGroupCheckedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ldap_group_checked, :integer, default: User.ldap_statuses[:unchecked]
  end
end
