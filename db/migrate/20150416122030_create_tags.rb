class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false, default: 'latest'
      t.integer :image_id, null: false

      t.timestamps null: false
    end
  end
end
