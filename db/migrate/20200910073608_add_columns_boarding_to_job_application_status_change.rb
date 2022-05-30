class AddColumnsBoardingToJobApplicationStatusChange < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :watheeq, :boolean, default: false
    add_column :job_application_status_changes, :performance_evaluation, :boolean, default: false
    add_column :job_application_status_changes, :on_boarding_session, :boolean, default: false
  end
end
