class AddNotifyJobseekerToJobApplicationStatusChange < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :notify_jobseeker, :boolean, default: false
  end
end
