class AddDescriptionToVulnerabilities < ActiveRecord::Migration[4.2]
  def change
    add_column :vulnerabilities, :description, :text
  end
end
