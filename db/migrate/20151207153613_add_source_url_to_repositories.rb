class AddSourceUrlToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :source_url, :string, null: false, default: ""
  end
end
