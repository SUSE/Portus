class AddGravatarToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gravatar, :boolean, default: true
  end
end
