class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name, default: nil

      t.timestamps null: false
    end
    add_index :repositories, :name, unique: true
  end
end
