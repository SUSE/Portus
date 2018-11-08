class RemoveLogFromCronoJob < ActiveRecord::Migration[4.2]
  def change
    remove_column :crono_jobs, :log, :text
  end
end
