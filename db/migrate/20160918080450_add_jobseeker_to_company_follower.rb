class AddJobseekerToCompanyFollower < ActiveRecord::Migration
  def change
    add_reference :company_followers, :jobseeker, index: true, foreign_key: :jobseeker_id
  end
end
