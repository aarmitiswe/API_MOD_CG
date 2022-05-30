class BudgetedVacancy < ActiveRecord::Base
  belongs_to :grade
  belongs_to :job_type
  belongs_to :job_experience_level
  belongs_to :section
  belongs_to :new_section
  belongs_to :department
  belongs_to :unit
end