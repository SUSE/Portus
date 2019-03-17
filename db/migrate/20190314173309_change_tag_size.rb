class ChangeTagSize < ActiveRecord::Migration[5.2]
  def change
     change_column :tags, :size, :bigint
  end
end
