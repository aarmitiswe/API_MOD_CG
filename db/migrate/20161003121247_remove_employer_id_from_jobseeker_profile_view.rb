class RemoveEmployerIdFromJobseekerProfileView < ActiveRecord::Migration
  def change
    remove_column :jobseeker_profile_views, :employer_id, :integer
  end
end
