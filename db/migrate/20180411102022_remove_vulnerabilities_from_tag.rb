class RemoveVulnerabilitiesFromTag < ActiveRecord::Migration
  def change
    remove_column :tags, :vulnerabilities, :text
  end
end
