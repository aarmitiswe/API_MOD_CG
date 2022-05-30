class CreateJobMatchingPercentages < ActiveRecord::Migration
  def change
    create_table :job_matching_percentages do |t|
      t.float :country
      t.float :city
      t.float :sector
      t.float :job_type
      t.float :education_level
      t.float :years_of_experience
      t.float :experience_level
      t.float :job_title
      t.float :department
      t.float :skills_focus_summary
      t.float :expecting_salary

      t.timestamps null: false
    end
  end
end
