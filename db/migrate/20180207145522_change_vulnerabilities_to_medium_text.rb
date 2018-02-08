class ChangeVulnerabilitiesToMediumText < ActiveRecord::Migration
  def change
    change_column :tags, :vulnerabilities, :text, limit: 16.megabytes - 1
  end
end
