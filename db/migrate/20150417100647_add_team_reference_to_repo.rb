class AddTeamReferenceToRepo < ActiveRecord::Migration
  def change
    add_belongs_to :repositories, :team, index: true
  end
end
