class SalaryAnalysisSerializer < ActiveModel::Serializer
  attributes :id, :basic_salary, :housing_allowance, :transportation_allowance, :special_allowance,
             :ticket_allowance, :education_allowance, :incentives, :monthly_salary, :level, :total_annual,
             :annual_incentives
end
