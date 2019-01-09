class AddSizeToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :size, :integer
  end
end
