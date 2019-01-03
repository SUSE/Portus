class AddDescriptionToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :description, :text
  end
end
