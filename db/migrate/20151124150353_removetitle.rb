class Removetitle < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :title
  end
end
