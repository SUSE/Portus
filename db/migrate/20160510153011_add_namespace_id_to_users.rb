class AddNamespaceIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :namespace, index: true, foreign_key: true, default: nil
  end
end
