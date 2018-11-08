class AddUsernameToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :username, :string
  end
end
