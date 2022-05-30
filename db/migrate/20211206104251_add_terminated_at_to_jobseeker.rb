class AddTerminatedAtToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :terminated_at, :datetime
  end
end
