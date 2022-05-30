class AddRejectionReasonToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :rejection_reason_one, :string
    add_column :job_requests, :rejection_reason_two, :string
    add_column :job_requests, :rejection_reason_three, :string
    add_column :job_requests, :rejection_reason_four, :string
    add_column :job_requests, :rejection_reason_five, :string
  end
end
