class RenameJobseekerJobToSavedJob < ActiveRecord::Migration
  def change
    rename_table :jobseeker_jobs, :saved_jobs
  end
end
