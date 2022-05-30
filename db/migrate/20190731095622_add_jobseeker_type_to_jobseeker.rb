class AddJobseekerTypeToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :jobseeker_type, :string, default: "normal"
  end
end
