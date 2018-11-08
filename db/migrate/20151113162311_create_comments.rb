class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.string :title
      t.text :body
      t.references :repository, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
