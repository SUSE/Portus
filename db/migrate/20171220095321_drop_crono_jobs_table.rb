class DropCronoJobsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :crono_jobs
  end
end
