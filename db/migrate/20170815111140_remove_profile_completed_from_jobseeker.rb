class RemoveProfileCompletedFromJobseeker < ActiveRecord::Migration
  def change
    Jobseeker.update_complete_step_column
    remove_column :jobseekers, :profile_completed, :boolean
  end
end
