class CreateVulnerabilities < ActiveRecord::Migration[4.2]
  def change
    create_table :vulnerabilities do |t|
      t.string :name, null: false
      t.string :scanner, null: false, default: ""

      t.string :severity, null: false, default: ""
      t.string :link, null: false, default: ""
      t.string :fixed_by, null: false, default: ""
      t.text :metadata
      t.timestamps null: false
    end

    add_index :vulnerabilities, :name, unique: true
  end
end
