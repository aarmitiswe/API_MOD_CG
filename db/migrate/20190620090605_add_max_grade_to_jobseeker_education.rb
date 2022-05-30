class AddMaxGradeToJobseekerEducation < ActiveRecord::Migration
  def change
    add_column :jobseeker_educations, :max_grade, :integer
  end
end
