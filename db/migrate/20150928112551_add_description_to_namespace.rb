class AddDescriptionToNamespace < ActiveRecord::Migration[4.2]
  def change
    add_column :namespaces, :description, :text
  end
end
