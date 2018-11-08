class AddImageIdToTag < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :image_id, :string, default: ""
  end
end
