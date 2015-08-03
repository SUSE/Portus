class CreateFsLayers < ActiveRecord::Migration
  def change
    create_table :fs_layers, primary_key: :blob_sum, id: false do |t|
      t.string :blob_sum, null: false
      t.column :tag_id, 'integer unsigned not null'
    end
    add_index :fs_layers, :tag_id
  end
end
