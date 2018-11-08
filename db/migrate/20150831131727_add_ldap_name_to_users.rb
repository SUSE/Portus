class AddLdapNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ldap_name, :string, default: nil
    add_index :users, :ldap_name, unique: true
  end
end
