class AddRequestForApprovalToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :request_for_approval, :boolean, default: false
  end
end
