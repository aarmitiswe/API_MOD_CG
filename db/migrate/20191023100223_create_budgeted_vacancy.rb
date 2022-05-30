class CreateBudgetedVacancy < ActiveRecord::Migration
  def change
    create_table :budgeted_vacancies do |t|
      t.string :job_title
      t.string :position_id
      t.references :grade, index: true
      t.references :job_experience_level, index: true
      t.references :job_type, index: true
      t.integer :no_vacancies
      t.timestamps null: false
    end
    add_foreign_key :budgeted_vacancies, :grades
    add_foreign_key :budgeted_vacancies, :job_types
    add_foreign_key :budgeted_vacancies, :job_experience_levels
  end
end
