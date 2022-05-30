class BudgetedVacancySerializer < ActiveModel::Serializer
  attributes :id, :job_title, :position_id, :no_vacancies
  has_one :grade
  has_one :job_type
  has_one :job_experience_level
  has_one :section
  has_one :new_section
  has_one :unit
  has_one :department

end