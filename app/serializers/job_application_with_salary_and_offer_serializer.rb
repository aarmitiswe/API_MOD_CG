class JobApplicationWithSalaryAndOfferSerializer < JobApplicationSerializer
  has_many :offer_analyses
  has_many :salary_analyses
end