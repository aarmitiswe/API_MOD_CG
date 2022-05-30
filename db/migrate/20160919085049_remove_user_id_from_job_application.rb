class RemoveUserIdFromJobApplication < ActiveRecord::Migration
  def change
    remove_column :job_applications, :user_id, :integer
  end
end
