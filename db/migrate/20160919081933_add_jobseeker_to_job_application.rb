class AddJobseekerToJobApplication < ActiveRecord::Migration
  def change
    add_reference :job_applications, :jobseeker, index: true, foreign_key: :jobseeker_id
  end
end
