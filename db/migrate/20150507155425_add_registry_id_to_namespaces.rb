class AddRegistryIdToNamespaces < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :namespaces, :registry, index: true
  end
end
