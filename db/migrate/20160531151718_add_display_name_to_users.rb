class AddDisplayNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :display_name, :string, default: nil
    add_index :users, :display_name, unique: true
  end
end
