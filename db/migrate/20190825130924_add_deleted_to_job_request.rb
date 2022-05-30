class AddDeletedToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :deleted, :boolean
  end
end
