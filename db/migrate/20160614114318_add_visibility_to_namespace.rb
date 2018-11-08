class AddVisibilityToNamespace < ActiveRecord::Migration[4.2]
  def up
    add_column :namespaces, :visibility, :integer
  end

  def down
    remove_column :namespaces, :visibility, :integer
  end
end
