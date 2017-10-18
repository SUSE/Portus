class AddIndexesToActivities < ActiveRecord::Migration
  def self.up
    add_index :activities, [:trackable_type]
  end

  def self.down
    remove_index :activities, [:trackable_type]
  end
end
