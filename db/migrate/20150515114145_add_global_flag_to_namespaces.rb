class AddGlobalFlagToNamespaces < ActiveRecord::Migration[4.2]
  def change
    add_column :namespaces, :global, :boolean, default: false
  end
end
