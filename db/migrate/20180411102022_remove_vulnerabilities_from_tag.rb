class RemoveVulnerabilitiesFromTag < ActiveRecord::Migration[4.2]
  def change
    remove_column :tags, :vulnerabilities, :text
  end
end
