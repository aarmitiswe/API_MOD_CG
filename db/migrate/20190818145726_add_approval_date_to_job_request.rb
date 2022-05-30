class AddApprovalDateToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :date_approval_one, :date
    add_column :job_requests, :date_approval_two, :date
    add_column :job_requests, :date_approval_three, :date
    add_column :job_requests, :date_approval_four, :date
    add_column :job_requests, :date_approval_five, :date
  end
end
