class AddPulledAtToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :pulled_at, :datetime, default: nil
  end
end
