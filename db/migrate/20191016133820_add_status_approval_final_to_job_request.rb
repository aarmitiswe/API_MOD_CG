class AddStatusApprovalFinalToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :status_approval_final, :string
  end
end
