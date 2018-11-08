class RemovePublicFromNamespace < ActiveRecord::Migration[4.2]
  def up
    remove_column :namespaces, :public, :boolean
  end

  def down
    add_column :namespaces, :public, :boolean
  end
end
