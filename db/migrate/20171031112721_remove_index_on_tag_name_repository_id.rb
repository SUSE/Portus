class RemoveIndexOnTagNameRepositoryId < ActiveRecord::Migration
  def change
    remove_index :tags, name: "index_tags_on_name_and_repository_id"
  end
end
