class AddArStatusToJobStatus < ActiveRecord::Migration
  def change
    add_column :job_statuses, :ar_status, :string
  end
end
