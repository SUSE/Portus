class AddNameToWebhooks < ActiveRecord::Migration[4.2]
  def change
		add_column :webhooks, :name, :string, null: false
  end
end
