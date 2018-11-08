class AddStatusAndDataToRegistryEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :registry_events, :status, :integer, default: RegistryEvent.statuses[:done]
    add_column :registry_events, :data, :text
  end
end
