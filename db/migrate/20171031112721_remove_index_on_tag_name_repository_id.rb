class RemoveIndexOnTagNameRepositoryId < ActiveRecord::Migration[4.2]
  def change
    remove_index :tags, name: "index_tags_on_name_and_repository_id"
  end
end
