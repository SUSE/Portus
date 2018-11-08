class AddUseSslToRegistries < ActiveRecord::Migration[4.2]
  def change
    add_column :registries, :use_ssl, :boolean
  end
end
