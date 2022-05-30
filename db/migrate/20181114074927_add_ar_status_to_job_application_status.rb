class AddArStatusToJobApplicationStatus < ActiveRecord::Migration
  def change
    add_column :job_application_statuses, :ar_status, :string
  end
end
