class AddDataToRegistryEvent < ActiveRecord::Migration
  def change
    add_column :registry_events, :data, :text
  end
end
