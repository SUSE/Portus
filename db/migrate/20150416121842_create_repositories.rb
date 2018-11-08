class CreateRepositories < ActiveRecord::Migration[4.2]
  def change
    create_table :repositories do |t|
      t.string :name, null: false, default: ''
      t.integer :namespace_id, default: nil

      t.timestamps null: false
    end
    add_index :repositories, :name, unique: true
    add_index :repositories, :namespace_id
  end
end
