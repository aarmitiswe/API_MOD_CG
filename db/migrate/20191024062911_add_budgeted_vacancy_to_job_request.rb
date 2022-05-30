class AddBudgetedVacancyToJobRequest < ActiveRecord::Migration
  def change
    add_reference :job_requests, :budgeted_vacancy, index: true, foreign_key: true
  end
end
