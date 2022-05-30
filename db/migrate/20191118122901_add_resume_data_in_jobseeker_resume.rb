class AddResumeDataInJobseekerResume < ActiveRecord::Migration
  def change
  	add_column :jobseeker_resumes, :resume_data, :text
  end
end
