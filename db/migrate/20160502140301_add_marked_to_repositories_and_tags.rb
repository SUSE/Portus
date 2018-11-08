class AddMarkedToRepositoriesAndTags < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :marked, :boolean, default: false
    add_column :tags, :marked, :boolean, default: false
  end
end
