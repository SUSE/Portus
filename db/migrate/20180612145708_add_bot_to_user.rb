class AddBotToUser < ActiveRecord::Migration
  def change
    add_column :users, :bot, :bool, default: false
  end
end
