class AddIsWaitingToJobApplicationStatusChange < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :is_waiting, :boolean, default: false
  end
end
