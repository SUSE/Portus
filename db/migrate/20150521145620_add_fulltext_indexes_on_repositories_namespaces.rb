require "portus/db"

class AddFulltextIndexesOnRepositoriesNamespaces < ActiveRecord::Migration[4.2]
  def change
    # This `if` statement has been added after this migration was
    # created. Modifying migrations is generally a *bad* idea but this will only
    # apply to PostgreSQL deployments that start from scratch, which haven't
    # been supported until now.
    if ::Portus::DB.mysql?
      add_index :namespaces, :name, type: :fulltext, name: 'fulltext_index_namespaces_on_name'
      add_index :repositories, :name, type: :fulltext, name: 'fulltext_index_repositories_on_name'
    end
  end
end
