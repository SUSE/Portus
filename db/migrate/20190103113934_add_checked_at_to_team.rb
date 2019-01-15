class AddCheckedAtToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :checked_at, :datetime, default: nil
  end
end
