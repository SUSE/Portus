class AddScannedAndVulnsToTag < ActiveRecord::Migration
  def change
    add_column :tags, :scanned, :integer, default: 0
    add_column :tags, :vulnerabilities, :text
  end
end
