class AddEnabledToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :enabled, :bool, default: true
  end
end
