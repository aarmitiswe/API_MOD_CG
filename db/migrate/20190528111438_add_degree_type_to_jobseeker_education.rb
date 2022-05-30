class AddDegreeTypeToJobseekerEducation < ActiveRecord::Migration
  def change
    add_column :jobseeker_educations, :degree_type, :string
  end
end
