class AddCompanyUserToJobseekerProfileView < ActiveRecord::Migration
  def change
    add_reference :jobseeker_profile_views, :company_user, index: true, foreign_key: :company_user_id
  end
end
