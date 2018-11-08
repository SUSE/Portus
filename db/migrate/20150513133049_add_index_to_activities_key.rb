class AddIndexToActivitiesKey < ActiveRecord::Migration[4.2]
  def change
    add_index :activities, :key
  end
end
