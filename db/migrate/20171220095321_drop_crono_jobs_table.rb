class DropCronoJobsTable < ActiveRecord::Migration
  def change
    drop_table :crono_jobs
  end
end
