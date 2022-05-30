class JobseekerEducation < ActiveRecord::Migration
  def change
    create_table :jobseeker_educations do |t|
      t.references :jobseeker, index: true
      t.references :job_education, index: true
      t.references :country
      t.references :city
      t.string :grade
      t.string :school
      t.string :field_of_study

      t.date :from
      t.date :to

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_educations, :jobseekers
    add_foreign_key :jobseeker_educations, :job_educations
  end
end
