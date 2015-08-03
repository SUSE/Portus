class AddArchitectureToTags < ActiveRecord::Migration
  def change
    add_column :tags, :architecture, :string
  end
end
