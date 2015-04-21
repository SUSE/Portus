class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name, null: false, default: ''
      t.integer :repository_id, default: nil

      t.timestamps null: false
    end
    add_index :images, :name, unique: true
    add_index :images, :repository_id
  end
end
