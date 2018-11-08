class AddBotToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :bot, :bool, default: false
  end
end
