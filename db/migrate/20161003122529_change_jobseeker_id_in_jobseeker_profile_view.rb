class ChangeJobseekerIdInJobseekerProfileView < ActiveRecord::Migration
  def change
    remove_column :jobseeker_profile_views, :jobseeker_id
    add_reference :jobseeker_profile_views, :jobseeker, index: true, foreign_key: :jobseeker_id
  end
end
