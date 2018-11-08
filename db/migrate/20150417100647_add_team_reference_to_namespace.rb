class AddTeamReferenceToNamespace < ActiveRecord::Migration[4.2]
  def change
    add_belongs_to :namespaces, :team, index: true
  end
end
