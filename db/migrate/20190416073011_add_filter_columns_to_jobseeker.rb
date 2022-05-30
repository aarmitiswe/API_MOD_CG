class AddFilterColumnsToJobseeker < ActiveRecord::Migration
  def change
    add_reference :jobseekers, :experience_range, index: true, foreign_key: :experience_range_id


    add_column :jobseekers, :current_salary_range_id, :integer, index: true
    add_foreign_key :jobseekers, :salary_ranges, column: :current_salary_range_id


    add_column :jobseekers, :expected_salary_range_id, :integer, index: true
    add_foreign_key :jobseekers, :salary_ranges, column: :expected_salary_range_id
  end
end
