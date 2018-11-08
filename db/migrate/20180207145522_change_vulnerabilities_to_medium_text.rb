class ChangeVulnerabilitiesToMediumText < ActiveRecord::Migration[4.2]
  def change
    change_column :tags, :vulnerabilities, :text, limit: 16.megabytes - 1
  end
end
