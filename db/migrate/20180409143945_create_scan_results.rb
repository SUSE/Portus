class CreateScanResults < ActiveRecord::Migration[4.2]
  def change
    create_table :scan_results do |t|
      t.integer :tag_id
      t.integer :vulnerability_id

      t.timestamps null: false
    end
  end
end
