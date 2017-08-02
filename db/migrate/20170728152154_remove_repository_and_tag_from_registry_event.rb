class RemoveRepositoryAndTagFromRegistryEvent < ActiveRecord::Migration
  def change
    remove_column :registry_events, :repository, :string
    remove_column :registry_events, :tag, :string
  end
end
