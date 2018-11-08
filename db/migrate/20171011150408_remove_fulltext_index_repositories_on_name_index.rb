class RemoveFulltextIndexRepositoriesOnNameIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index_if_exists :repositories, "fulltext_index_repositories_on_name"
    remove_index_if_exists :namespaces, "fulltext_index_namespaces_on_name"
  end

  def remove_index_if_exists(table, name)
    remove_index table, name: name if index_exists?(table, :name, name: name)
  end
end
