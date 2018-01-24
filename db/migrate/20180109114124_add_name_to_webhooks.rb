class AddNameToWebhooks < ActiveRecord::Migration
  def change
		add_column :webhooks, :name, :string, null: false
  end
end
