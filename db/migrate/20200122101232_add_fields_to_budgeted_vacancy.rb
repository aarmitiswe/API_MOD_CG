class AddFieldsToBudgetedVacancy < ActiveRecord::Migration
  def change
    add_reference :budgeted_vacancies, :section, index: true, foreign_key: true
    add_reference :budgeted_vacancies, :unit, index: true, foreign_key: true
    add_reference :budgeted_vacancies, :department, index: true, foreign_key: true
  end
end
