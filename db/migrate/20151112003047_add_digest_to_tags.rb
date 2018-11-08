class AddDigestToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :digest, :string
  end
end
