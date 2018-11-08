class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false, default: 'latest'
      t.integer :repository_id, null: false

      t.timestamps null: false
    end
    add_index :tags, :repository_id
  end
end
