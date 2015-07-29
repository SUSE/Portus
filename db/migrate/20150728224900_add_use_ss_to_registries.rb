class AddUseSsToRegistries < ActiveRecord::Migration
  def change
    add_column :registries, :use_ssl, :boolean, default: false
  end
end
