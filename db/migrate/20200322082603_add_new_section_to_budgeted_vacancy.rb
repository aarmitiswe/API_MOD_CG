class AddNewSectionToBudgetedVacancy < ActiveRecord::Migration
  def change
  	 add_reference :budgeted_vacancies, :new_section, index: true, foreign_key: true
  end
end
