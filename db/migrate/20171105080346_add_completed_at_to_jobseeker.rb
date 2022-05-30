class AddCompletedAtToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :completed_at, :datetime
  end
end
