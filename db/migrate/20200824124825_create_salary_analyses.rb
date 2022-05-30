class CreateSalaryAnalyses < ActiveRecord::Migration
  def change
    create_table :salary_analyses do |t|
      t.references :job_application, index: true, foreign_key: true
      t.decimal :basic_salary
      t.decimal :housing_allowance
      t.decimal :transportation_allowance
      t.decimal :special_allowance
      t.decimal :ticket_allowance
      t.decimal :education_allowance
      t.decimal :incentives
      t.decimal :monthly_salary
      t.integer :level

      t.timestamps null: false
    end
  end
end
