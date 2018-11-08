class AddAuthorToComment < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :comments, :user, index: true
  end
end
