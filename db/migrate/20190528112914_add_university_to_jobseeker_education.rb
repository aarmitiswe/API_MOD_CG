class AddUniversityToJobseekerEducation < ActiveRecord::Migration
  def change
    add_reference :jobseeker_educations, :university, index: true, foreign_key: :university_id
  end
end
