class AddHandledToRegistryEvents < ActiveRecord::Migration
  def change
    add_column :registry_events, :handled, :integer, default: RegistryEvent.statuses[:done]
  end
end
