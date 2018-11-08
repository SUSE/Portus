class RemoveRepositoryAndTagFromRegistryEvent < ActiveRecord::Migration[4.2]
  def change
    remove_column :registry_events, :repository, :string
    remove_column :registry_events, :tag, :string
  end
end
