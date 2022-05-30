class AddCompanyToJobseekerProfileView < ActiveRecord::Migration
  def change
    add_reference :jobseeker_profile_views, :company, index: true, foreign_key: :company_id
  end
end
