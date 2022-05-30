class CreateJobseekerSkills < ActiveRecord::Migration
  def change
    create_table :jobseeker_skills do |t|
      t.references :jobseeker, index: true
      t.references :skill, index: true
      t.integer :level

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_skills, :jobseekers
    add_foreign_key :jobseeker_skills, :skills
  end
end
