class AddOnBoardingStatusToJobApplicationStatusChange < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :on_boarding_status, :string
  end
end
