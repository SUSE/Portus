class AddAuthorToTag < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :tags, :user, index: true
  end
end
