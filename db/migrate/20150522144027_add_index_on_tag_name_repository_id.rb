class AddIndexOnTagNameRepositoryId < ActiveRecord::Migration[4.2]
  def change
    add_index :tags, [:name, :repository_id], unique: true
  end
end
