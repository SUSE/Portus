class AddExternalHostnameToRegistries < ActiveRecord::Migration[4.2]
  def change
    add_column :registries, :external_hostname, :string
  end
end
